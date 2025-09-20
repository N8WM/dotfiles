# Oh-My-Posh
OMP_THEME="$CONFIG_DIR/ohmyposh/custom.omp.toml"
if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]] && command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config "$OMP_THEME")"
fi
