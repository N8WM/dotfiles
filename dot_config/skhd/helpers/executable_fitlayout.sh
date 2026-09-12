#!/usr/bin/env bash
set -euo pipefail

# Some apps refuse to shrink past a minimum size. yabai lays out the bsp tree as if every
# resize it asked for succeeded, so a window that clamps is bigger than the slot it was
# given. That shows up two ways, depending on where the window sits:
#
#   - on the right/bottom of the tree it hangs off the edge of the screen
#   - anywhere else it overlaps its neighbour
#
# Both mean the same thing: the slot is too small. The fix is to move the split so the
# slot grows to the size the window actually insisted on, and the neighbour gives up the
# difference.
#
# Runs on the window_resized signal, which is the moment an app clamps.
#
# Only oversized windows are corrected. Underflow (a window with a maximum size that
# cannot grow to fill its slot, leaving a gap) is measurable the same way but is
# deliberately left alone for now.

TOLERANCE=2 # px of rounding noise to ignore
COOLDOWN=1  # seconds; stops a correction that causes a new clamp from ping-ponging

MENU_BAR_CACHE="$HOME/.cache/yabai/menu_bar_height"

SPACEQ="$(yabai -m query --spaces --space)"
IFS=$'\t' read -r SPACE_TYPE SPACE_INDEX < <(jq -r '[.type, .index] | @tsv' <<<"$SPACEQ")

# Only bsp spaces have splits to move
[[ "$SPACE_TYPE" == "bsp" ]] || exit 0

STAMP="$HOME/.cache/yabai/fitlayout_last_${SPACE_INDEX}"
LOCK="$HOME/.cache/yabai/fitlayout.lock"
mkdir -p "$(dirname "$STAMP")"

# window_resized fires once per affected window, so several copies of this script start at
# the same moment. Without a lock they all read the same pre-correction frames, all pass
# the cooldown check below, and all apply the same correction — moving the fence two or
# three times as far as intended. mkdir is atomic, so exactly one copy gets through.
if ! mkdir "$LOCK" 2>/dev/null; then
  # Clear a lock left behind by an instance that was killed before it could clean up
  if [[ -n "$(find "$LOCK" -maxdepth 0 -mmin +1 2>/dev/null)" ]]; then
    rmdir "$LOCK" 2>/dev/null || true
  fi
  exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

# Don't correct again straight away: a correction can make the neighbour clamp, and its
# resize event would bring us right back here.
NOW="$(date +%s)"
if [[ -f "$STAMP" ]] && (($(cat "$STAMP") + COOLDOWN > NOW)); then
  exit 0
fi

WINDOWSQ="$(yabai -m query --windows --space)"

# A window being dragged is the user's business, not ours. Note is-grabbed is broader than
# it sounds: it is true whenever a mouse button is held over a window, including a plain
# click-drag inside it such as selecting text. That over-suppresses slightly, but only
# matters if a resize happens to land while a button is down, since nothing else wakes
# this script. Press the balance binding to recover if a correction is ever missed.
if jq -e 'any(.[]; ."is-grabbed")' >/dev/null <<<"$WINDOWSQ"; then
  exit 0
fi

# Tiled windows only, and one entry per stack rather than one per card.
# Minimized and hidden windows must be excluded: they stay is-floating == false but keep
# the frame they had before they went away, and that stale rectangle will happily match
# the overlap test against a live window.
TILED="$(jq -c '[.[] | select(
  ."is-floating" == false and
  ."is-minimized" == false and
  ."is-hidden" == false and
  ."stack-index" <= 1
)]' <<<"$WINDOWSQ")"
[[ "$(jq 'length' <<<"$TILED")" -ge 2 ]] || exit 0

if [[ ! -f "$MENU_BAR_CACHE" ]]; then
  osascript -e 'tell application "System Events" to get the size of the menu bar of process "Finder"' |
    awk -F', ' '{print $2}' >"$MENU_BAR_CACHE"
fi
MENU_BAR="$(($(cat "$MENU_BAR_CACHE") + 1))"

GAP="$(yabai -m config window_gap)"
IFS=$'\t' read -r PAD_T PAD_B PAD_L PAD_R < <(
  printf '%s\t%s\t%s\t%s\n' \
    "$(yabai -m config top_padding)" "$(yabai -m config bottom_padding)" \
    "$(yabai -m config left_padding)" "$(yabai -m config right_padding)"
)

IFS=$'\t' read -r DX DY DW DH < <(
  yabai -m query --displays --display |
    jq -r '[.frame.x, .frame.y, .frame.w, .frame.h] | map(floor) | @tsv'
)

USABLE_L=$((DX + PAD_L))
USABLE_T=$((DY + MENU_BAR + PAD_T))
USABLE_R=$((DX + DW - PAD_R))
USABLE_B=$((DY + DH - PAD_B))

IDS=() XS=() YS=() WS=() HS=()
while IFS=$'\t' read -r ID X Y W H; do
  IDS+=("$ID") XS+=("$X") YS+=("$Y") WS+=("$W") HS+=("$H")
done < <(jq -r '.[] | [.id, .frame.x, .frame.y, .frame.w, .frame.h] | map(floor) | @tsv' <<<"$TILED")

COUNT=${#IDS[@]}

# Grow one window's slot by moving the fence on the given side, then stop. One correction
# per event, plus the lock and cooldown above, is what bounds this. If the window still
# doesn't fit afterwards (it is the outermost pane, or its neighbour has a minimum too)
# the resize simply fails and we leave the layout alone.
apply_correction() {
  local id="$1" side="$2" amount="$3"
  echo "$NOW" >"$STAMP"
  case "$side" in
  left) yabai -m window "$id" --resize left:-"${amount}":0 || true ;;
  right) yabai -m window "$id" --resize right:"${amount}":0 || true ;;
  top) yabai -m window "$id" --resize top:0:-"${amount}" || true ;;
  bottom) yabai -m window "$id" --resize bottom:0:"${amount}" || true ;;
  esac
  exit 0
}

# Hanging off the screen: take the space back from the opposite side
for ((i = 0; i < COUNT; i++)); do
  OVER_R=$((XS[i] + WS[i] - USABLE_R))
  OVER_B=$((YS[i] + HS[i] - USABLE_B))
  OVER_L=$((USABLE_L - XS[i]))
  OVER_T=$((USABLE_T - YS[i]))

  ((OVER_R > TOLERANCE)) && apply_correction "${IDS[i]}" left "$OVER_R"
  ((OVER_B > TOLERANCE)) && apply_correction "${IDS[i]}" top "$OVER_B"
  ((OVER_L > TOLERANCE)) && apply_correction "${IDS[i]}" right "$OVER_L"
  ((OVER_T > TOLERANCE)) && apply_correction "${IDS[i]}" bottom "$OVER_T"
done

# Overlapping a neighbour: push the fence between them toward that neighbour
for ((i = 0; i < COUNT; i++)); do
  for ((j = 0; j < COUNT; j++)); do
    [[ "$i" == "$j" ]] && continue

    # Side by side (their vertical extents meet) and i is the left one
    if ((YS[i] < YS[j] + HS[j])) && ((YS[j] < YS[i] + HS[i])) && ((XS[i] < XS[j])); then
      NEED=$((XS[i] + WS[i] + GAP - XS[j]))
      ((NEED > TOLERANCE)) && apply_correction "${IDS[i]}" right "$NEED"
    fi

    # Stacked (their horizontal extents meet) and i is the upper one
    if ((XS[i] < XS[j] + WS[j])) && ((XS[j] < XS[i] + WS[i])) && ((YS[i] < YS[j])); then
      NEED=$((YS[i] + HS[i] + GAP - YS[j]))
      ((NEED > TOLERANCE)) && apply_correction "${IDS[i]}" bottom "$NEED"
    fi
  done
done

# Nothing needed correcting. Explicit so the exit status never depends on which of the
# arithmetic tests above happened to run last.
exit 0
