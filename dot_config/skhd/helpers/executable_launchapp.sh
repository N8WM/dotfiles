#!/usr/bin/env bash
set -euo pipefail

MANIFEST="${HOME}/.config/skhd/launcher.json"
HOTKEY="${1:?launcher hotkey required}"

command -v jq >/dev/null 2>&1 || {
  echo "jq not found" >&2
  exit 1
}

[[ -r "$MANIFEST" ]] || {
  echo "Launcher manifest not found: $MANIFEST" >&2
  exit 1
}

ENTRY="$(jq -cer --arg key "$HOTKEY" '.[] | select(.key == $key)' "$MANIFEST" | head -n 1)"
[[ -n "$ENTRY" ]] || exit 0

APP="$(jq -r '.app' <<<"$ENTRY")"
CMD="$(jq -r '.cmd // empty' <<<"$ENTRY")"

if [[ -n "$CMD" ]]; then
  eval "$CMD"
else
  open -a "$APP"
fi
