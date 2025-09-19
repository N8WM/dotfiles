#!/usr/bin/env bash
set -euo pipefail

CONFIG="${HOME}/.config/yabai/autoopen.json"

# Make sure jq exists
command -v jq >/dev/null 2>&1 || {
  echo "jq not found" >&2
  exit 1
}

# Read current space index
CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index')

# Load JSON once (avoids process substitution / mapfile)
APPS_JSON=$(cat "$CONFIG")

# Loop over config entries in order
count=$(jq 'length' <<<"$APPS_JSON")
TARGET_APP=""
TARGET_CMD=""

i=0
while [ "$i" -lt "$count" ]; do
  app=$(jq -r ".[$i].app" <<<"$APPS_JSON")
  cmd=$(jq -r ".[$i].cmd // empty" <<<"$APPS_JSON")

  # Look for a yabai rule mapping this app to CURRENT_SPACE
  # We only consider rules whose label starts with "app-space-"
  if yabai -m rule --list | jq -e --arg app "$app" --argjson s "$CURRENT_SPACE" '
      .[]
      | select(.label | startswith("app-space-"))
      | {space, app: (.app | sub("^\\^";"") | sub("\\$";""))}
      | select(.space == $s and .app == $app)
    ' >/dev/null; then
    TARGET_APP="$app"
    TARGET_CMD="$cmd"
    break
  fi

  i=$((i + 1))
done

# Nothing mapped for this space
[ -z "$TARGET_APP" ] && exit 0

# Already open?
if yabai -m query --windows | jq -r '.[].app' | sort -u | grep -Fxq -- "$TARGET_APP"; then
  exit 0
fi

# Open with special command if provided; else default open -a
if [ -n "$TARGET_CMD" ]; then
  echo "Running special open command: $TARGET_CMD"
  eval "$TARGET_CMD"
else
  open -a "$TARGET_APP"
fi
