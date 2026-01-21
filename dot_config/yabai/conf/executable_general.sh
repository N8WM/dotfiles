# Debug and Error Logging

# To view the last lines of the error log, use:
# tail -f /tmp/yabai_$USER.err.log

# To view the last lines of the debug log, use:
# tail -f /tmp/yabai_$USER.out.log

yabai -m config debug_output on

# Tiling Options

# Override default layout for space 1 only
yabai -m config --space 1 layout float

# New window spawns to the left if vertical split, or top if horizontal split
# yabai -m config window_placement first_child

# New window spawns to the right if vertical split, or bottom if horizontal split
yabai -m config window_placement second_child

# Padding and Gaps

# Set all padding and gaps (default: 0)
yabai -m config top_padding 20
yabai -m config bottom_padding 20
yabai -m config left_padding 20
yabai -m config right_padding 20
yabai -m config window_gap 12

# Override gaps for space 2 only
# yabai -m config --space 2 window_gap 0

# Split Ratios

# auto_balance automatically readjusts windows to occupy the same space
# on or off (default: off)
yabai -m config auto_balance off

# Floating point value between 0 and 1 (default: 0.5)
yabai -m config split_ratio 0.5

# Mouse Support

# set mouse interaction modifier key (default: fn)
yabai -m config mouse_modifier alt

# set modifier + left-click drag to move window (default: move)
yabai -m config mouse_action1 move

# set modifier + right-click drag to resize window (default: resize)
yabai -m config mouse_action2 resize

# set focus follows mouse mode (default: off, options: off, autoraise, autofocus)
yabai -m config focus_follows_mouse autofocus

# set mouse follows focus mode (default: off)
yabai -m config mouse_follows_focus on

# Status Bar

# add 20 padding to the top and 0 padding to the bottom of every space located on the main display
# yabai -m config external_bar main:20:0
# add 20 padding to the top and bottom of all spaces regardless of the display it belongs to
# yabai -m config external_bar all:20:20

# Focus window after active space changes
yabai -m signal --add event=space_changed action="yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id)"

# Focus window after active display changes
yabai -m signal --add event=display_changed action="yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id)"

# Automatically open apps when opening specific spaces if the app isn't open yet
yabai -m signal --add event=space_changed action="~/.config/yabai/helpers/space_opens_app.sh"
