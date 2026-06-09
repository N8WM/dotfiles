MODE="$1"

case "$MODE" in
default)
  borders active_color=0xffc9cdd4 inactive_color=0x00494d64 width=9.0 style=uniform &
  ;;

normal)
  borders active_color=0xff7aa2f7 inactive_color=0x00494d64 width=9.0 style=uniform &
  ;;

visual)
  borders active_color=0xffbb9af7 inactive_color=0x00494d64 width=9.0 style=uniform &
  ;;
esac
