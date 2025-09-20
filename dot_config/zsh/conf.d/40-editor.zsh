# Choose first available editor
preferred_editors=(nvim vim vi nano)
for editor in "${preferred_editors[@]}"; do
  if command -v "$editor" >/dev/null 2>&1; then
    export EDITOR="$editor"
    export VISUAL="$editor"
    break
  fi
done

alias vi="$EDITOR"
alias vim="$EDITOR"
alias nvim="$EDITOR"
