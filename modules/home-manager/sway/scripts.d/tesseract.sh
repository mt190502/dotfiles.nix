#!/bin/bash
#################################################
##
#### Tesseract helper
##
#################################################
ocrdata=$(mktemp)
tmpdata=$(mktemp)

@grim@ -g "$(@slurp@)" - >"$tmpdata"
@tesseract@ "$tmpdata" stdout -l eng+tur --psm 6 2>/dev/null | sed -E -e '/^[[:space:]]*$/b' -e ':a;N;$!ba;s/([^[:space:]])\n/\1 /g' | sed 's/\n//g' >"$ocrdata"
[[ ! -s "$ocrdata" ]] && exit

case $@ in
--extract | -e)
	out="$(@wofi@ --show dmenu --prompt "OCR" -n -k /dev/null <"$ocrdata")"
	;;
--translate | -t)
	out="$(@trans@ -brief :tr - <"$ocrdata" | @wofi@ --show dmenu --prompt "Translator" -n -k /dev/null)"
	;;
esac

[[ -n "$out" ]] && echo "$out" | @wl_clipboard@/bin/wl-copy
rm "$ocrdata" "$tmpdata"
