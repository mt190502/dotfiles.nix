{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    functions = {
      cd = "builtin cd $argv; lsd";
    };

    generateCompletions = false;

    loginShellInit = ''
      if [ $XDG_VTNR = 1 ]; and [ $SHLVL = 1 ]; and [ ! $container ]
      		export $(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
      		export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring
      		export SSH_AUTH_SOCK=$GNOME_KEYRING_CONTROL/ssh
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
      sysdup = "sudo dnf --refresh upgrade && nix-channel --update && flatpak update && hm .#fedora";

      #~ Git
      gita = "git add -A";
      gitca = "git commit -a";
      gitcm = "git commit -m";
      gitch = "git checkout";
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
      export TERM="xterm-256color"
      export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:$HOME/.local/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS"
      export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:/usr/local/go/bin:$HOME/go/bin:$HOME/scripts:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

      ##################################################
      #
      ## Applications
      #
      ##################################################
      #~ common ~#
      direnv export fish | source
      helm completion fish | source
      hugo completion fish | source
      kubectl completion fish | source
      tailscale completion fish | source

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

      #~ grc ~#
      for cmd in g++ gas head make ld ping6 tail traceroute6 $( ls ${pkgs.grc}/share/grc/ | grep -vE 'jobs|systemctl' )
        set cmd "$(echo $cmd | sed 's/conf\.//g')"
        type "$cmd" >/dev/null 2>&1 && alias "$cmd"="$( which grc ) --colour=auto $cmd"
      end 
    '';
  };
}
