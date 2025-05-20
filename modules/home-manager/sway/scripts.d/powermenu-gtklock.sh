#!@bash@
#################################################
##
#### PowerMenu
##
#################################################
[[ "$1" == "--lock" ]] && { gtklock && sleep 3 && exit 0; }
[[ "$1" == "--suspend" ]] && { gtklock && sleep 3 && systemctl suspend; exit 0; }

#~~~ menu
MODE=$(swaynag -t theme -m PowerMenu -Z Shutdown 'echo 0' -Z Reboot 'echo 1' -Z Suspend 'echo 2' -Z Hibernate 'echo 3' -Z Lock 'echo 4' -Z Logout 'echo 5')
[[ -z "$MODE" ]] && exit
CONFIRM=$(swaynag -t theme -m Confirm? -Z No 'echo no' -Z Yes 'echo yes')
[[ $CONFIRM != "yes" ]] && exit
case $MODE in
0)
    systemctl poweroff
    ;;
1)
    systemctl reboot -i
    ;;
2)
    gtklock
    systemctl suspend
    ;;
3)
    gtklock
    systemctl hibernate
    ;;
4)
    gtklock
    ;;
5)
    rm "$XDG_RUNTIME_DIR/.autostart"
    @sway@/bin/swaymsg exit
    ;;
*)
    echo "No command specified..."
    ;;
esac
