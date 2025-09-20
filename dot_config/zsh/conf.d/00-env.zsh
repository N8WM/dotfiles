# Correctly display UTF-8 with combining characters
if [[ "$(locale LC_CTYPE)" == "UTF-8" ]]; then
  setopt COMBINING_CHARS
fi
