#!@bash@
#################################################
##
#### Program Toggler
##
#################################################
[[ -z "$1" ]] && exit

if [[ "$1" =~ "/nix" ]]; then
	program=$(echo "$1" | awk -F '/' '{print $NF}')
	[[ -n "${*:2}" ]] && program+=" ${*:2}"
# shellcheck disable=SC2009
	mapfile -t PID_LIST < <(ps aux | grep -vE "grep|programtoggle" | grep -i "$program" | awk '{print $2}')
else
# shellcheck disable=SC2009
	mapfile -t PID_LIST < <(ps aux | grep -vE "grep|programtoggle" | grep -i "$*" | awk '{print $2}')
fi

if [[ -n "${PID_LIST[*]}" ]]; then
	for PID in "${PID_LIST[@]}"; do
		pgrep -P "$PID" | xargs kill -9
		kill -9 "$PID"
	done
else
	"$@" &
fi