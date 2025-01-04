{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.pkgconfig.fish = {
    enable = lib.mkEnableOption "Enable fish shell configuration.";
  };

  config.programs.fish = {
    enable = config.pkgconfig.fish.enable;

    functions = {
      cd = "builtin cd $argv; lsd";
    };

    generateCompletions = false;

    loginShellInit = ''
      if [ $XDG_VTNR = 1 ]; and [ $SHLVL = 1 ]; and [ ! $container ]
      		export $(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
      		export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring
      		export SSH_AUTH_SOCK=$GNOME_KEYRING_CONTROL/ssh
      		export PATH
      		dbus-update-activation-environment --systemd --all
      		XDG_CURRENT_DESKTOP=sway sway &>$HOME/.cache/swaywm.log
      	end
    '';

    plugins = [
      {
        name = "nvm";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "nvm.fish";
          rev = "2.2.16";
          sha256 = "sha256-GTEkCm+OtxMS3zJI5gnFvvObkrpepq1349/LcEPQRDo=";
        };
      }
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "4.4.5";
          sha256 = "sha256-VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";
        };
      }
    ];

    shellAliases = {
      #~ Containers
      a = "ansible";
      ap = "clear; ansible-playbook";
      d = "docker";
      k = "kubectl";
      tbox = "toolbox";

      #~ System
      cp = "cp -i";
      crontab = "crontab -i";
      ls = "lsd";
      mv = "mv -i";
      rm = "rm -i";

      #~ Git
      gita = "git add -A";
      gitca = "git commit -a";
      gitcm = "git commit -m";
      gitp = "git push";
      gitpp = "git pull";

      #~ Utilities
      ff = "fastfetch";
      passgen = "cat /dev/urandom | tr -dc [:alnum:] | head -c";
      tldr = "cht.sh";
      tmp = "cd ~/.tmp";
    };

    shellInit = ''
      ##################################################
      #
      ## Fish Variables
      #
      ##################################################
      set fish_greeting ""
      set TERM "xterm-256color"
      set XDG_DATA_DIRS "$HOME/.local/share/flatpak/exports/share:$HOME/.local/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS"
      set PATH "$HOME/.local/share/JetBrains/Toolbox/scripts:/usr/local/go/bin:$HOME/go/bin:$HOME/scripts:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

      ##################################################
      #
      ## Applications
      #
      ##################################################
      #~ common ~#
      direnv export fish | source
      #docker completion fish | source
      #helm completion fish | source
      hugo completion fish | source
      kubectl completion fish | source
      tailscale completion fish | source
      #velero completion fish | source

      #~ nvm ~#
      #set -gx NVM_DIR "$HOME/.nvm"
      #set -gx NODE_VERSION $(cat $HOME/.nvmrc | head -n 1)

      #~ pnpm ~#
      #set -gx PNPM_HOME "$HOME/.local/share/pnpm"
      #if not string match -q $PNPM_HOME $PATH
      #  set -gx PATH $PNPM_HOME/bin $PATH
      #end

      #~ rust ~# 
      #source "$HOME/.cargo/env.fish"
    '';
  };
}
