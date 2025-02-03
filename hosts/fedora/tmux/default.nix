{ ... }:

{
  programs.tmux = {
    enable = true;

    baseIndex = 1;
    clock24 = true;
    escapeTime = 30;
    historyLimit = 30000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-b";
    sensibleOnTop = false;
    terminal = "xterm";

    extraConfig = ''
      #################################################
      #### General 
      #################################################
      #~ global settings
      set -g  display-panes-time  800
      set -g  display-time        1000
      set -g  renumber-windows    off
      set -g  repeat-time         600
      set -g  set-titles          on
      set -g  status-interval     10
      set -g  status-position     top

      #~ session-based settings
      set -s  focus-events        on

      #~ window-based settings
      setw -g xterm-keys          on


      #################################################
      #### Keybindings
      #################################################
      bind-key -n S-Left     split-pane    -h
      bind-key -n S-Right    split-pane    -h
      bind-key -n S-Up       split-pane    -v
      bind-key -n S-Down     split-pane    -v
      bind-key -n C-S-Left   select-pane   -L
      bind-key -n C-S-Right  select-pane   -R
      bind-key -n C-S-Up     select-pane   -U
      bind-key -n C-S-Down   select-pane   -D

      bind-key -n C-t        new-window

      bind s setw            synchronize-panes on
      bind S setw            synchronize-panes off

      bind r run             '"$TMUX_PROGRAM" ''${TMUX_SOCKET:+-S "$TMUX_SOCKET"} source "$TMUX_CONF"\; source "$OMT_CONF_LOCAL"' \; display "Reloaded!"


      #################################################
      #### oh-my-tmux engine
      #################################################
      %if #{==:#{TMUX_PROGRAM},}
        run 'TMUX_PROGRAM="$(LSOF=$(PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" command -v lsof); $LSOF -b -w -a -d txt -p #{pid} -Fn 2>/dev/null | perl -n -e "if (s/^n((?:.(?!dylib$|so$))+)$/\1/g && s/(?:\s+\([^\s]+?\))?$//g) { print; exit } } exit 1; {" || readlink "/proc/#{pid}/exe" 2>/dev/null || printf tmux)"; "$TMUX_PROGRAM" -S #{socket_path} set-environment -g TMUX_PROGRAM "$TMUX_PROGRAM"'
      %endif
      %if #{==:#{TMUX_SOCKET},}
        run '"$TMUX_PROGRAM" -S #{socket_path} set-environment -g TMUX_SOCKET "#{socket_path}"'
      %endif
      %if #{==:#{OMT_CONF},}
        run '"$TMUX_PROGRAM" set-environment -g OMT_CONF "$HOME/.config/tmux/omt.conf"'
      %endif
      %if #{==:#{OMT_CONF_LOCAL},}
        run '"$TMUX_PROGRAM" set-environment -g OMT_CONF_LOCAL "$HOME/.config/tmux/omt.conf.local"'
      %endif
      %if #{==:#{TMUX_CONF},}
        run '"$TMUX_PROGRAM" set-environment -g TMUX_CONF "$HOME/.config/tmux/tmux.conf"'
      %endif

      run '"$TMUX_PROGRAM" source "$OMT_CONF_LOCAL"'
      run 'cut -c3- "$OMT_CONF" | sh -s _apply_configuration'
    '';
  };

  xdg.configFile = {
    "tmux/omt.conf".source = ./config/omt.conf;
    "tmux/omt.conf.local".source = ./config/omt.conf.local;
  };
}
