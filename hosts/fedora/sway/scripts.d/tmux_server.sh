#!/bin/bash
#################################################
##
#### Tmux server
##
#################################################
while true; do
	@tmux@ ls | grep -q daemonmodetmux || { cd "$HOME" && @tmux@ new-session -ds daemonmodetmux; }
	@tmux@ ls | grep -q dropterminaltmux || { cd "$HOME" && @tmux@ new-session -ds dropterminaltmux; }
	sleep 1
done
