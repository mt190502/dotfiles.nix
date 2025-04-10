#!/bin/bash
#################################################
##
#### Workspace creator for per monitor
##
#################################################
[[ -z $1 ]] && {
	notify-send "No mode specified..."
	exit
}
[[ -z $2 ]] && {
	notify-send "No workspace specified..."
	exit
}
active_monitor=$(@sway@/bin/swaymsg -t get_outputs | @jq@ -r '.[] | select (.focused) | .name')
case $1 in
init)
	for monitor in $(@sway@/bin/swaymsg -t get_workspaces | @jq@ -r ".[].output"); do
		@sway@/bin/swaymsg workspace "1-$monitor" output "$monitor"
		@sway@/bin/swaymsg workspace "1-$monitor"
	done
	;;
switch)
	@sway@/bin/swaymsg workspace "$2-$active_monitor" output "$active_monitor"
	@sway@/bin/swaymsg workspace "$2-$active_monitor"
	;;
move-container)
	@sway@/bin/swaymsg move container to workspace "$2-$active_monitor"
	;;
esac
