RANGE=80
WINDOW="${YABAI_WINDOW_ID:-}"

IS_FLOATING=$(yabai -m query --windows --window | jq -r '."is-floating"')
SPACE_TYPE=$(yabai -m query --spaces --space | jq -r '.type')

[[ $IS_FLOATING == "false" ]] && [[ $SPACE_TYPE != "float" ]] && exit 0

yabai -m window $WINDOW --grid 6:6:1:1:4:4

WINDOW_COUNT=$(yabai -m query --windows --space | jq 'length')

[[ $WINDOW_COUNT -lt 2 ]] && exit 0

X_OFFSET=$((RANDOM % (RANGE * 2 + 1) - RANGE))
Y_OFFSET=$((RANDOM % (RANGE * 2 + 1) - RANGE))

yabai -m window $WINDOW --move rel:${X_OFFSET}:${Y_OFFSET}
