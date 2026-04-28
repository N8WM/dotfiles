# Update yabai
function yabai-update() {
  yabai --stop-service && success=true || success=false
  curl -L https://raw.githubusercontent.com/asmvik/yabai/master/scripts/install.sh | sh /dev/stdin ~/.local/bin ~/.local/man

  if [ "$success" = true ]; then
    yabai --start-service
  fi
}

# Dotfiles command dispatch
function dot() {
  local cmd=$1

  if [[ -z $cmd ]]; then
    dot_usage
    return 1
  else
    shift
  fi

  case "$cmd" in
    e|edit) dot_edit "$@" ;;
    a|apply) dot_apply "$@" ;;
    s|sync) dot_sync "$@" ;;
    st|stat|status) chezmoi status ;;
    g|git) chezmoi git "$@" ;;
    push) dot_push "$@" ;;
    pull) chezmoi git pull ;;
    *)
   printf 'Unknown dot subcommand: %s\n' "$cmd" >&2
      return 1
      ;;
  esac
}

function dot_usage() {
  echo "Usage: dot COMMAND [ARGS]"
  printf "\n$(which dot)\n"
}

# Edit chezmoi-managed dotfiles
function dot_edit() {
  if [[ -n $1 ]]; then
    chezmoi edit "$CONFIG_DIR/$1"
  else
    chezmoi edit
  fi
}

# Apply chezmoi-managed dotfiles from source
function dot_apply() {
  if [[ -n $1 ]]; then
    chezmoi apply "$CONFIG_DIR/$1"
  else
    chezmoi apply
  fi
}

# Update chezmoi-managed dotfiles from local
function dot_sync() {
  dir="$HOME/.local/share/chezmoi"
  chezmoi managed | chezmoi re-add && chezmoi apply
}

# Push chezmoi-managed dotfiles to remote
function dot_push() {
  set -euo pipefail
  msg="${1:-"update"}"
  dir="$HOME/.local/share/chezmoi"

  if [ -z "$(git -C $dir status --porcelain)" ]; then
    echo "No changes to commit"
    return 0
  fi

  git -C $dir add .
  git -C $dir commit -m "$msg"
  git -C $dir push
}
