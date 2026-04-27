#!@bash@

pname=$(basename @player@)
if [ "@preferred_terminal@" == "alacritty" ]; then
    term_cmd="@alacritty@ -t $pname -e"
    app_id="Alacritty"
elif [ "@preferred_terminal@" == "foot" ]; then
    term_cmd="@foot@ -T $pname "
    app_id="foot"
fi
scrwidth=$(@swaymsg@ -t get_outputs | @jq@ -r '.[] | select(.focused) | .rect.width')
@swaymsg@ for_window "[app_id=\"$app_id\" title=\"$pname\"] move position $(((scrwidth * 25) / 100)) 0"
"$HOME"/.local/bin/program-toggler $term_cmd @player@