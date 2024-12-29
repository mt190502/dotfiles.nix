#!/bin/bash
#################################################
##
#### Dropdown terminal
##
#################################################
#~~~ set term and get screen size
TERM=@alacritty@
scrwidth=$(@sway@/bin/swaymsg -t get_outputs | @jq@ -r '.[] | select(.focused) | .rect.width')

#~~~ if dropdown term is not started
if ! pgrep -f dropterminal; then
	@sway@/bin/swaymsg for_window "[app_id=\"Alacritty\" title=\"dropterminal\"] move container to scratchpad"
	sleep 0.15
	$TERM -t dropterminal -e @tmux@ attach-session -t dropterminaltmux &
	sleep 0.15
fi
@sway@/bin/swaymsg "[app_id=\"Alacritty\" title=\"dropterminal\"] scratchpad show, resize set 50ppt 50ppt, floating enable, move position $(((scrwidth * 25) / 100)) 0"
