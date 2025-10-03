#!@bash@
#################################################
##
#### Workspace creator for per monitor
##
#################################################
[[ -z $1 ]] && {
	@notify-send@ "No mode specified..."
	exit
}
[[ -z $2 ]] && {
	@notify-send@ "No workspace specified..."
	exit
}
active_monitor=$(@hyprctl@ -j monitors | @jq@ -r '.[] | select(.focused==true) | .name')
case $1 in
init)
	for monitor in $(@hyprctl@ -j workspaces | @jq@ -r '.[].monitor'); do
		@hyprctl@ keyword workspace "1,monitor:$monitor,name:1-$monitor"
		@hyprctl@ dispatch workspace "name:1-$monitor"
	done
	;;
switch)
	@hyprctl@ keyword workspace "$2,monitor:$active_monitor,name:$2-$active_monitor"
	@hyprctl@ dispatch workspace "name:$2-$active_monitor"
	;;
move-container)
	@hyprctl@ dispatch movetoworkspace "name:$2-$active_monitor"
	;;
esac
