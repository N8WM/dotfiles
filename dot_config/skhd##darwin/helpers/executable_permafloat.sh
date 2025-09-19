#!/usr/bin/env bash
set -euo pipefail

MANAGED_FILE="${HOME}/.config/yabai/conf/managed.sh"
LABEL_PREFIX="app-manage-" # prefix avoids collisions

mkdir -p "$(dirname "$MANAGED_FILE")"
touch "$MANAGED_FILE"

# Focused app
FOCUSED_APP="$(yabai -m query --windows --window | jq -r '.app // empty')"
[ -n "$FOCUSED_APP" ] && [ "$FOCUSED_APP" != "null" ] || exit 0

APP_ARG="app=\"^${FOCUSED_APP}\$\""
SAFE_APP_FOR_LABEL="$(printf "%s" "$FOCUSED_APP" |
  tr '[:upper:]' '[:lower:]' |
  tr -c '[:alnum:]' '-')"
LABEL="${LABEL_PREFIX}${SAFE_APP_FOR_LABEL}"

# Helper: apply an action (float/unfloat + optional grid) to all windows of an app
apply_to_windows_of_app() {
  local app="$1" action="$2" grid="${3:-}"
  local ids
  ids="$(yabai -m query --windows | jq -r --arg app "$app" \
    '.[] | select(.app == $app) | .id')"
  [ -n "$ids" ] || return 0

  case "$action" in
  float)
    echo "Floating all \"$app\" windows..."
    for wid in $ids; do
      if [ -n "$grid" ]; then
        yabai -m window "$wid" --toggle float --grid "$grid" || true
      else
        yabai -m window "$wid" --toggle float || true
      fi
    done
    ;;
  unfloat)
    echo "Unfloating all \"$app\" windows..."
    for wid in $ids; do
      yabai -m window "$wid" --toggle float || true
    done
    ;;
  esac
}

# If already remembered: toggle OFF
if grep -Fq -- "$APP_ARG" "$MANAGED_FILE"; then
  echo "Toggling OFF manage rule for \"$FOCUSED_APP\" (label=${LABEL})"

  TMP="$(mktemp)"
  grep -Fv -- "$APP_ARG" "$MANAGED_FILE" >"$TMP" || true
  mv "$TMP" "$MANAGED_FILE"

  yabai -m rule --remove "$LABEL" 2>/dev/null || true
  apply_to_windows_of_app "$FOCUSED_APP" unfloat
  exit 0
fi

# Not remembered yet: add rule + float all windows
echo "Adding \"$FOCUSED_APP\" to perma-manage-off (label=${LABEL})"

TMP="$(mktemp)"
grep -Fv -- "$APP_ARG" "$MANAGED_FILE" >"$TMP" || true
mv "$TMP" "$MANAGED_FILE"

RULE=(yabai -m rule --add "label=${LABEL}" "${APP_ARG}" "manage=off")
printf "%s\n" "${RULE[*]}" >>"$MANAGED_FILE"
"${RULE[@]}"

# Float + grid all windows (your original behavior but extended to all)
apply_to_windows_of_app "$FOCUSED_APP" float "6:6:1:1:4:4"
