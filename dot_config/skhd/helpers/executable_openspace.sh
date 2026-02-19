SPACE_REQUESTED="${1:?space index required}"
MOVE_FOCUSED_WINDOW="${2:-false}"

CURRENT_DISPLAY="$(yabai -m query --displays --display | jq -r '.index')"

ensure_target_exists() {
  local target="$1"
  local n
  n="$(yabai -m query --spaces --display "$CURRENT_DISPLAY" | jq -r 'length')"
  while ((n < target)); do
    yabai -m space --create
    ((n++))
  done
}

last_space_with_window() {
  yabai -m query --spaces --display "$CURRENT_DISPLAY" |
    jq -r '([ .[] | select((.windows // []) | length > 0) ] | last | .index) // 0'
}

trim_trailing_spaces() {
  local keep_up_to="$1"
  local n i
  n="$(yabai -m query --spaces --display "$CURRENT_DISPLAY" | jq -r 'length')"
  for ((i = n; i > keep_up_to; i--)); do
    yabai -m space --destroy "$i"
  done
}

ensure_target_exists "$SPACE_REQUESTED"

if [[ "$MOVE_FOCUSED_WINDOW" == "true" ]]; then
  FOCUSED_WINDOW="$(yabai -m query --windows --window | jq -r '.id')"

  yabai -m window --space "$SPACE_REQUESTED"
  yabai -m space --focus "$SPACE_REQUESTED"
  yabai -m window --focus "$FOCUSED_WINDOW"

  "$HOME/.config/skhd/helpers/autoposition.sh"
else
  yabai -m space --focus "$SPACE_REQUESTED"
fi

LAST_SPACE_WITH_WINDOW="$(last_space_with_window)"

KEEP_UP_TO="$LAST_SPACE_WITH_WINDOW"
if ((SPACE_REQUESTED > KEEP_UP_TO)); then
  KEEP_UP_TO="$SPACE_REQUESTED"
fi
if ((KEEP_UP_TO < 4)); then
  KEEP_UP_TO=4
fi

trim_trailing_spaces "$KEEP_UP_TO"
