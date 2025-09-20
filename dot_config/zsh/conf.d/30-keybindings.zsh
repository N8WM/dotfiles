typeset -A key

# Prefer zkbd under $ZDOTDIR
_fallback=1
_zkbddir="$ZDOTDIR/.zkbd"
_candidates=(
  "$_zkbddir/${TERM}-${VENDOR}-${OSTYPE}"
  "$_zkbddir/${TERM}-${VENDOR}"
  "$_zkbddir/${TERM}"
)

for _zkbd in "${_candidates[@]}"; do
  if [[ -r "$_zkbd" ]]; then
    source "$_zkbd"
    _fallback=0
    break
  fi
done

if [[ "$_fallback" ]]; then
  # Terminfo fallback
  key[Home]="${terminfo[khome]}"
  key[End]="${terminfo[kend]}"
  key[Delete]="${terminfo[kdch1]}"
  key[Insert]="${terminfo[kich1]}"
  key[PageUp]="${terminfo[kpp]}"
  key[PageDown]="${terminfo[knp]}"
  key[Up]="${terminfo[kcuu1]}"
  key[Down]="${terminfo[kcud1]}"
  key[Left]="${terminfo[kcub1]}"
  key[Right]="${terminfo[kcuf1]}"
fi

[[ -n ${key[Home]}   ]] && bindkey "${key[Home]}"   beginning-of-line
[[ -n ${key[End]}    ]] && bindkey "${key[End]}"    end-of-line
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[Left]}   ]] && bindkey "${key[Left]}"   backward-char
[[ -n ${key[Right]}  ]] && bindkey "${key[Right]}"  forward-char
