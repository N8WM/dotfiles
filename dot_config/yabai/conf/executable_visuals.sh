# Window Modifications

# modify window shadows (default: on, options: on, off, float)
# example: show shadows only for floating windows
yabai -m config window_shadow float

# window opacity (default: off, options: on, off)
# example: render all unfocused windows with 90% opacity
yabai -m config window_opacity off

# yabai -m config active_window_opacity 1.0
# yabai -m config normal_window_opacity 1.0

# Window animations
yabai -m config window_animation_duration 0.08

# Status bar

# Optionally disable native status bar entirely
# yabai -m config menubar_opacity 0.9

# Show borders
borders active_color=0xffc9cdd4 inactive_color=0x00494d64 width=9.0 style=uniform &
