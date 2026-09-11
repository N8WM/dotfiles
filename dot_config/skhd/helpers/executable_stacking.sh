#!/usr/bin/env bash
set -euo pipefail

# Stack a window onto another one, in two presses:
#   1. focus the window you want to move, run this  -> it is marked, borders turn red
#   2. focus the window you want it stacked onto, run this again -> it moves there
# Running it twice on the same window cancels the mark.
#
# yabai's `window --stack <id>` moves the *given* window onto the *focused* one,
# so the marked id is passed as the argument and the destination is whatever
# happens to be focused on the second press.

MARK_FILE="$HOME/.cache/yabai/stack_mark"
BORDERMODE="$HOME/.config/skhd/helpers/bordermode.sh"

mkdir -p "$(dirname "$MARK_FILE")"

FOCUSED="$(yabai -m query --windows --window | jq -r '.id')"

set_mark() {
  echo "$1" >"$MARK_FILE"
  "$BORDERMODE" stack
}

clear_mark() {
  rm -f "$MARK_FILE"
  "$BORDERMODE" default
}

# Nothing marked yet: mark the focused window and wait for a destination
if [[ ! -f "$MARK_FILE" ]]; then
  set_mark "$FOCUSED"
  exit 0
fi

MARKED="$(cat "$MARK_FILE")"

# Same window twice: cancel
if [[ "$MARKED" == "$FOCUSED" ]]; then
  clear_mark
  exit 0
fi

# Marked window is gone (closed while marked): start over from here
if ! yabai -m query --windows --window "$MARKED" >/dev/null 2>&1; then
  set_mark "$FOCUSED"
  exit 0
fi

# yabai cannot stack across spaces, so drop the mark instead of failing
MARKED_SPACE="$(yabai -m query --windows --window "$MARKED" | jq -r '.space')"
FOCUSED_SPACE="$(yabai -m query --windows --window "$FOCUSED" | jq -r '.space')"
if [[ "$MARKED_SPACE" != "$FOCUSED_SPACE" ]]; then
  clear_mark
  exit 0
fi

# Stack it, then follow it: yabai leaves focus on the destination, which ends up
# buried under the window that just arrived.
yabai -m window --stack "$MARKED"
yabai -m window --focus "$MARKED"
clear_mark
