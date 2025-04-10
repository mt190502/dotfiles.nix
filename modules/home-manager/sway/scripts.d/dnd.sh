#!/bin/bash
#################################################
##
#### Mako Do-Not-Disturb mode toggler
##
#################################################

togglemode() {
	if [ "$(@mako@/bin/makoctl mode)" == "dnd" ]; then
		@mako@/bin/makoctl mode -s default &>/dev/null
		rm -f "$XDG_RUNTIME_DIR/dnd_enabled"
		pkill -RTMIN+9 waybar
	else
		@mako@/bin/makoctl mode -s dnd &>/dev/null
		echo enabled >"$XDG_RUNTIME_DIR/dnd_enabled"
		pkill -RTMIN+9 waybar
	fi
}

status() {
	if [[ ! -e "$XDG_RUNTIME_DIR/dnd_enabled" ]]; then
		_status="DND Inactive"
		# shellcheck disable=SC2089
		output="{\"text\": \"\", \"alt\": \" ${_status}\", \"tooltip\": \" ${_status}\"}"
	else
		_status="DND Active"
		# shellcheck disable=SC2089
		output="{\"text\": \"\", \"alt\": \" ${_status}\", \"tooltip\": \" ${_status}\"}"
	fi
	echo "$output"
}

main() {
	case $@ in
	status)
		status
		;;
	*)
		togglemode
		;;
	esac
}

main "$@"
