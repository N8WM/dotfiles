alias omp="oh-my-posh"
alias ls='gls --color=auto'

alias vnew="mkdir .venv && python3 -m venv ./.venv"
alias vact="source ./.venv/bin/activate"
alias vdeact="deactivate"
alias vrm="rm -rf .venv"
alias vclean="pip freeze | xargs pip uninstall -y"

alias inv='vim $(fzf -m --preview="bat --color=always {}")'
