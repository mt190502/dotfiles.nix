#!/bin/bash
#################################################
##
#### Program Toggler
##
#################################################
[[ -z "$1" ]] && exit

# shellcheck disable=SC2009
mapfile -t PID_LIST < <(ps aux | grep -vE "grep|programtoggle" | grep -i "$*" | awk '{print $2}')

if [[ -n "${PID_LIST[*]}" ]]; then
	for PID in "${PID_LIST[@]}"; do
		pgrep -P "$PID" | xargs kill -9
		kill -9 "$PID"
	done
else
	"$@" &
fi
