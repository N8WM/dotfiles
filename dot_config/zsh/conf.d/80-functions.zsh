# Update yabai
function yabai-update() {
  yabai --stop-service && success=true || success=false
  curl -L https://raw.githubusercontent.com/koekeishiya/yabai/master/scripts/install.sh | sh /dev/stdin ~/.local/bin ~/.local/man

  if [ "$success" = true ]; then
    yabai --start-service
  fi
}

# Push chezmoi-managed dotfiles to git repo
function chad() (
  set -euo pipefail
  msg="${1:-"update"}"
  dir="$HOME/.local/share/chezmoi"

  chezmoi managed | chezmoi re-add && chezmoi apply

  if [ -z "$(git -C $dir status --porcelain)" ]; then
    echo "No changes to commit"
    return 0
  fi

  git -C $dir add .
  git -C $dir commit -m "$msg"
  git -C $dir push
)
