#!@bash@
scrwidth=$(@sway@/bin/swaymsg -t get_outputs | @jq@ -r '.[] | select(.focused) | .rect.width')
@sway@/bin/swaymsg for_window "[app_id=\"Alacritty\" title=\"ncmpcpp\"] move position $(((scrwidth * 25) / 100)) 0"
"$HOME"/.config/sway/scripts.d/programtoggle.sh @alacritty@ -T ncmpcpp -e @ncmpcpp@