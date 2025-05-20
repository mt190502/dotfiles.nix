#!@bash@
#################################################
##
#### PowerMenu
##
#################################################
#~~~ lock function
blurlock() {
    [[ -n "$(pgrep swaylock)" ]] && exit
    for output in $(@sway@/bin/swaymsg -t get_outputs | @jq@ -r '.[].name'); do
        image="$HOME/.cache/$output-lock"
        [[ -e $image ]] && rm "$image"
        @grim@ -l 1 -o "$output" "$image.png"
        @imagemagick@/bin/convert -blur 0x10 "$image.png" "$image-blurred.png"
        args="$args --image $output:$image-blurred.png"
    done
    # shellcheck disable=SC2086
    swaylock --daemonize $args &
    until pgrep swaylock; do sleep .5; done
    return 0
}

[[ "$1" == "--lock" ]] && { blurlock && sleep 3 && exit 0; }
[[ "$1" == "--suspend" ]] && { blurlock && sleep 3 && systemctl suspend; exit 0; }

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
    blurlock
    systemctl suspend
    ;;
3)
    blurlock
    systemctl hibernate
    ;;
4)
    blurlock
    ;;
5)
    rm "$XDG_RUNTIME_DIR/.autostart"
    @sway@/bin/swaymsg exit
    ;;
*)
    echo "No command specified..."
    ;;
esac
