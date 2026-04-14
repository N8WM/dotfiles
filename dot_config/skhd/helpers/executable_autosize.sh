#!/usr/bin/env bash
set -euo pipefail

TARGET_W=1200
TARGET_H=779
TOLERANCE=50
MARGIN=20
WINDOW="${YABAI_WINDOW_ID:-}"

WINDOWQ="$(yabai -m query --windows --window $WINDOW)"

IS_FLOATING="$(jq -r '."is-floating"' <<<"$WINDOWQ")"
IS_VISIBLE="$(jq -r '."is-visible"' <<<"$WINDOWQ")"
CAN_RESIZE="$(jq -r '."can-resize"' <<<"$WINDOWQ")"
CAN_MOVE="$(jq -r '."can-move"' <<<"$WINDOWQ")"

SPACE="$(jq -r '."space"' <<<"$WINDOWQ")"
SPACE_TYPE="$(yabai -m query --spaces --space $SPACE | jq -r '.type')"

[[ "$IS_FLOATING" == "false" ]] && [[ "$SPACE_TYPE" != "float" ]] && exit 0
[[ "$IS_VISIBLE" == "false" ]] && exit 0
[[ "$CAN_RESIZE" == "false" ]] && exit 0
[[ "$CAN_MOVE" == "false" ]] && exit 0

APP="$(jq -r '.app' <<<"$WINDOWQ")"
UNMANAGED="$(yabai -m rule --list | jq -r --arg app "$APP" \
  '[.[] | select(.app == "^\($app)$" and .manage == false)] | length')"

[[ "$UNMANAGED" -gt 0 ]] && exit 0

# Read cached menu bar height, regenerate if missing
MENU_BAR_CACHE="$HOME/.cache/yabai/menu_bar_height"
if [[ ! -f "$MENU_BAR_CACHE" ]]; then
  mkdir -p "$(dirname "$MENU_BAR_CACHE")"
  osascript -e 'tell application "System Events" to get the size of the menu bar of process "Finder"' \
    | awk -F', ' '{print $2}' > "$MENU_BAR_CACHE"
fi
MENU_BAR="$(( $(cat "$MENU_BAR_CACHE") + 1 ))"

# Determine target dimensions
FRAME="$(jq -r '.frame' <<<"$WINDOWQ")"
CURRENT_W="$(jq -r '.w | floor' <<<"$FRAME")"
CURRENT_H="$(jq -r '.h | floor' <<<"$FRAME")"

DIFF_W=$(( CURRENT_W - TARGET_W ))
DIFF_H=$(( CURRENT_H - TARGET_H ))
[[ "$DIFF_W" -lt 0 ]] && DIFF_W=$(( -DIFF_W ))
[[ "$DIFF_H" -lt 0 ]] && DIFF_H=$(( -DIFF_H ))

NEEDS_RESIZE=false
if [[ "$DIFF_W" -gt "$TOLERANCE" ]] || [[ "$DIFF_H" -gt "$TOLERANCE" ]]; then
  NEEDS_RESIZE=true
  WIN_W=$TARGET_W
  WIN_H=$TARGET_H
else
  WIN_W=$CURRENT_W
  WIN_H=$CURRENT_H
fi

ORIG_X="$(jq -r '.x | floor' <<<"$FRAME")"
ORIG_Y="$(jq -r '.y | floor' <<<"$FRAME")"
WIN_X=$ORIG_X
WIN_Y=$ORIG_Y

DISPLAY_FRAME="$(yabai -m query --displays --display | jq '.frame')"
DISPLAY_W="$(jq -r '.w | floor' <<<"$DISPLAY_FRAME")"
DISPLAY_H="$(jq -r '.h | floor' <<<"$DISPLAY_FRAME")"

# Center if only window on space
WINDOW_COUNT="$(yabai -m query --windows --space $SPACE | jq 'length')"

if [[ "$WINDOW_COUNT" -lt 2 ]]; then
  WIN_X=$(( (DISPLAY_W - WIN_W) / 2 ))
  WIN_Y=$(( MENU_BAR + (DISPLAY_H - MENU_BAR - WIN_H) / 2 ))
fi

# Clamp to margin
[[ "$WIN_X" -lt "$MARGIN" ]] && WIN_X=$MARGIN
TOP_MARGIN=$(( MENU_BAR + MARGIN ))
[[ "$WIN_Y" -lt "$TOP_MARGIN" ]] && WIN_Y=$TOP_MARGIN
[[ $(( WIN_X + WIN_W )) -gt $(( DISPLAY_W - MARGIN )) ]] && WIN_X=$(( DISPLAY_W - MARGIN - WIN_W ))
[[ $(( WIN_Y + WIN_H )) -gt $(( DISPLAY_H - MARGIN )) ]] && WIN_Y=$(( DISPLAY_H - MARGIN - WIN_H ))

# Only move if position changed
if [[ "$WIN_X" -ne "$ORIG_X" ]] || [[ "$WIN_Y" -ne "$ORIG_Y" ]]; then
  yabai -m window $WINDOW --move abs:${WIN_X}:${WIN_Y}
fi

if [[ "$NEEDS_RESIZE" == "true" ]]; then
  yabai -m window $WINDOW --resize abs:${TARGET_W}:${TARGET_H}
fi
