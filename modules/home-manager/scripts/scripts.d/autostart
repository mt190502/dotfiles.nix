#!@bash@
#################################################
#
## Autostart Most Used Apps
#
#################################################
#~ wait 3 seconds
sleep 3

# file syntax: workspace_number:monitor_name|kind:value|app_with_args
# example    : 1:HDMI-1|app_id:firefox|firefox --new-window https://www.google.com

[[ -e "$XDG_RUNTIME_DIR/.autostart" ]] && exit
while IFS= read -r line; do
	[[ -z "$line" || "$line" =~ ^# ]] && continue

	IFS='|' read -r ws option app <<<"$line"
    IFS=':' read -r workspace monitor <<<"$ws"
    IFS=':' read -r kind value <<<"$option"

    [[ "$workspace" != "none" ]] && @sway@/bin/swaymsg "workspace $workspace-$monitor output $monitor"
    [[ "$kind" != "none" ]] && @sway@/bin/swaymsg "for_window [$kind=\"$value\"] move container workspace $workspace-$monitor"
    eval "$app" &
    disown
    sleep 1
done <"$HOME/.autostart"
touch "$XDG_RUNTIME_DIR/.autostart"

