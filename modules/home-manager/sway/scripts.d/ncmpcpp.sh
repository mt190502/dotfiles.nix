#!@bash@
scrwidth=$(@swaymsg@ -t get_outputs | @jq@ -r '.[] | select(.focused) | .rect.width')
@swaymsg@ for_window "[app_id=\"Alacritty\" title=\"ncmpcpp\"] move position $(((scrwidth * 25) / 100)) 0"
"$HOME"/.local/bin/program-toggler @alacritty@ -T ncmpcpp -e @ncmpcpp@