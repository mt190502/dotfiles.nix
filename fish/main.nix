{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    functions = { cd = "builtin cd $argv; lsd"; };

    generateCompletions = true;

    loginShellInit =
      "	if [ $XDG_VTNR = 1 ]; and [ $SHLVL = 1 ]; and [ ! $container ]\n		export $(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)\n		export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring\n		export SSH_AUTH_SOCK=$GNOME_KEYRING_CONTROL/ssh\n		export PATH\n		dbus-update-activation-environment --systemd --all\n		XDG_CURRENT_DESKTOP=sway sway &>$HOME/.cache/swaywm.log\n	end\n";

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

    shellInit =
      "	##################################################\n	#\n	## Fish Variables\n	#\n	##################################################\n	set fish_greeting \"\"\n	set TERM \"xterm-256color\"\n	set XDG_DATA_DIRS \"$HOME/.local/share/flatpak/exports/share:$HOME/.local/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS\"\n	set PATH \"$HOME/.local/share/JetBrains/Toolbox/scripts:/usr/local/go/bin:$HOME/go/bin:$HOME/scripts:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH\"\n\n\n	##################################################\n	#\n	## Applications\n	#\n	##################################################\n	#~ common ~#\n	direnv export fish | source\n	docker completion fish | source\n	helm completion fish | source\n	hugo completion fish | source\n	kubectl completion fish | source\n	tailscale completion fish | source\n	velero completion fish | source\n\n	#~ nvm ~#\n	set -gx NVM_DIR \"$HOME/.nvm\"\n	set -gx NODE_VERSION $(cat $HOME/.nvmrc | head -n 1)\n\n	#~ pnpm ~#\n	set -gx PNPM_HOME \"$HOME/.local/share/pnpm\"\n	if not string match -q $PNPM_HOME $PATH\n		set -gx PATH $PNPM_HOME/bin $PATH\n	end\n\n	#~ rust ~# \n	source \"$HOME/.cargo/env.fish\"\n";
  };

  home.activation = {
    postInstall = ''
      $SHELL -c "fisher install ilancosman/tide" &>/dev/null
    '';
  };
}
