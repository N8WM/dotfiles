# Completion style
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Docker Desktop completions
_docker_comp="$HOME/.docker/completions"
if [[ -d "$_docker_comp" ]]; then
  fpath=("$_docker_comp" $fpath)
fi

