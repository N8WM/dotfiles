# Update yabai
function yabai-update() {
  yabai --stop-service && stopped=true || stopped=false

  # reinstall yabai (remove old service file because homebrew changes binary path)
  echo "Uninstalling yabai service..."
  yabai --uninstall-service
  echo "Reinstalling brew tap..."
  brew reinstall asmvik/formulae/yabai
  echo "Requesting new codesign certificate..."
  codesign -fs "yabai-cert" "$(brew --prefix yabai)/bin/yabai"

  if [ "$stopped" = true ]; then
    echo "Restarting yabai..."
    yabai --start-service
  fi

  echo "Done."
  echo
  echo "Consider updating the sudoers file with:"
  echo "yabai-sudoers"
}

function yabai-sudoers() {
  echo "Updating sudoers file..."
  echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
  echo "Done."
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

function ds() {
  local dir="${1:-.}"
  local choice
  local -a files

  if [[ ! -d "$dir" ]]; then
    print -u2 "ds: not a directory: $dir"
    return 1
  fi

  files=("$dir"/**/.DS_Store(ND))

  if (( ${#files} == 0 )); then
    print "No .DS_Store files found."
    return 0
  fi

  print "Found ${#files} .DS_Store file(s) under: $dir"

  while true; do
    read "choice?[p]review, [d]elete, [q]uit: "

    case "$choice" in
      p|P)
        printf '%s\n' "${files[@]}" | less
        ;;
      d|D|y|Y)
        if rm -- "${files[@]}"; then
          print "Deleted ${#files} .DS_Store file(s)."
          return 0
        else
          print -u2 "ds: one or more files could not be deleted."
          return 1
        fi
        ;;
      q|Q|n|N)
        print "Cancelled."
        return 0
        ;;
      *)
        print "Please enter p, d, or q."
        ;;
    esac
  done
}
