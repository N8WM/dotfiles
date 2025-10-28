_brewprefix="$(brew --prefix 2>/dev/null)"

# Autojump
_ajpath="$_brewprefix/etc/profile.d/autojump.sh"
[[ -f "$_ajpath" ]] && source "$_ajpath"

# zsh-autosuggestions
_aspath="$_brewprefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$_aspath" ]] && source "$_aspath"

# zsh-syntax-highlighting
_shpath="$_brewprefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -f "$_shpath" ]] && source "$_shpath"

# pyenv init (root is in .zprofile)
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# fzf — prefer its provided script
# command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
_fzfcpath="$_brewprefix/opt/fzf/shell/completion.zsh"
_fzfkbpath="$_brewprefix/opt/fzf/shell/key-bindings.zsh"
[[ -r "$_fzfcpath" ]] && source "$_fzfcpath"
[[ -r "$_fzfkbpath" ]] && source "$_fzfkbpath"
