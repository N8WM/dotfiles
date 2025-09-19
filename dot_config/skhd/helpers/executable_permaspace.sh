#!/usr/bin/env bash
set -euo pipefail

APP_SPACES_FILE="${HOME}/.config/yabai/conf/app_spaces.sh"
LABEL_PREFIX="app-space-"

mkdir -p "$(dirname "$APP_SPACES_FILE")"
touch "$APP_SPACES_FILE"

# Focused app
FOCUSED_APP="$(yabai -m query --windows --window | jq -r '.app // empty')"
[ -n "$FOCUSED_APP" ] && [ "$FOCUSED_APP" != "null" ] || exit 0

# Current space index
SPACE_INDEX="$(yabai -m query --spaces --space | jq -r '.index')"
[ -n "$SPACE_INDEX" ] && [ "$SPACE_INDEX" != "null" ] || {
  echo "Could not determine current space index." >&2
  exit 1
}

# Exact-match app arg used in the file
APP_ARG="app=\"^${FOCUSED_APP}\$\""

# Make a label that's safe (lowercase, non-alnum -> '-')
SAFE_APP_FOR_LABEL="$(printf "%s" "$FOCUSED_APP" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '-')"
LABEL="${LABEL_PREFIX}${SAFE_APP_FOR_LABEL}"

# Find existing line (if any)
EXISTING_LINE="$(grep -F -- "$APP_ARG" "$APP_SPACES_FILE" || true)"
if [ -n "$EXISTING_LINE" ]; then
  # Parse existing space index (after 'space=^')
  EXISTING_SPACE="$(printf "%s" "$EXISTING_LINE" | awk -F 'space=\\^' 'NF>1 {print $2}' | awk '{print $1}' | head -n1)"
  if [ "$EXISTING_SPACE" = "$SPACE_INDEX" ]; then
    # TOGGLE OFF: remove from file and (try to) remove live rule by label
    echo "Toggling off: removing \"$FOCUSED_APP\" from remembered space"
    TMP="$(mktemp)"
    grep -Fv -- "$APP_ARG" "$APP_SPACES_FILE" >"$TMP" || true
    mv "$TMP" "$APP_SPACES_FILE"
    # Remove live rule (ok if it doesn't exist yet)
    yabai -m rule --remove "$LABEL" 2>/dev/null || true
    exit 0
  fi
fi

# Update to new space: drop any old line for this app
TMP="$(mktemp)"
grep -Fv -- "$APP_ARG" "$APP_SPACES_FILE" >"$TMP" || true
mv "$TMP" "$APP_SPACES_FILE"

# Build rule WITH label and write it to the file
RULE=(yabai -m rule --add "label=${LABEL}" "${APP_ARG}" "space=^${SPACE_INDEX}")
printf "%s\n" "${RULE[*]}" >>"$APP_SPACES_FILE"

# Apply immediately
"${RULE[@]}"

echo "Remembering: \"$FOCUSED_APP\" → space ^${SPACE_INDEX} (label=${LABEL})"
