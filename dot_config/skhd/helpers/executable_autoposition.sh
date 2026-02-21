RANGE=80
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

yabai -m window $WINDOW --grid 6:6:1:1:4:4

WINDOW_COUNT="$(yabai -m query --windows --space $SPACE | jq 'length')"

[[ "$WINDOW_COUNT" -lt 2 ]] && exit 0

X_OFFSET=$((RANDOM % (RANGE * 2 + 1) - RANGE))
Y_OFFSET=$((RANDOM % (RANGE * 2 + 1) - RANGE))

yabai -m window $WINDOW --move rel:${X_OFFSET}:${Y_OFFSET}
