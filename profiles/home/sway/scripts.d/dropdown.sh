#!@bash@
#################################################
##
#### Dropdown terminal
##
#################################################
#~~~ set term and get screen size
scrwidth=$(@swaymsg@ -t get_outputs | @jq@ -r '.[] | select(.focused) | .rect.width')

if [ "@preferred_terminal@" == "alacritty" ]; then
    term_cmd="@alacritty@ -t dropterminal -e"
    app_id="Alacritty"
elif [ "@preferred_terminal@" == "foot" ]; then
    term_cmd="@foot@ -T dropterminal "
    app_id="foot"
fi

#~~~ if dropdown term is not started
if ! pgrep -f dropterminal; then
	@swaymsg@ for_window "[app_id=\"$app_id\" title=\"dropterminal\"] move container to scratchpad"
	sleep 0.15
	$term_cmd @tmux@ new-session -A -s dropterminaltmux &
	sleep 0.15
fi
@swaymsg@ "[app_id=\"$app_id\" title=\"dropterminal\"] scratchpad show, resize set 50ppt 50ppt, floating enable, move position $(((scrwidth * 25) / 100)) 0"
