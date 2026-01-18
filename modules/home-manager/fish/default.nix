{
  config,
  flakeName,
  lib,
  pkgs,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  home = config.home.homeDirectory;
in
{
  options.moduleopts.home-manager.fish = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "fish";
    };
  };
  config = lib.mkIf cfg.fish.enable {
    programs.fish =
      let
        inherit (pkgs) ansible grc;
        cht_sh = lib.getExe pkgs.cht-sh;
        direnv = lib.getExe pkgs.direnv;
        fastfetch = lib.getExe pkgs.fastfetch;
        gh = lib.getExe pkgs.gh;
        git = lib.getExe pkgs.git;
        helm = lib.getExe pkgs.kubernetes-helm;
        hugo = lib.getExe pkgs.hugo;
        kubectl = lib.getExe pkgs.kubectl;
        kubecolor = lib.getExe pkgs.kubecolor;
        kubetail = lib.getExe pkgs.kubetail;
        lsd = lib.getExe pkgs.lsd;
        neovide = lib.getExe pkgs.neovide;
        telnet = lib.getExe' pkgs.inetutils "telnet";
        trash = lib.getExe pkgs.trash-cli;
        yt_dlp = lib.getExe pkgs.yt-dlp;
      in
      {
        enable = true;
        functions = {
          cd = "builtin cd $argv; ${lsd}";
          acx = {
            wraps = "aws configure list-profiles";
            body = ''
              if test (count $argv) -eq 0
                aws configure list-profiles
                return 1
              end
              export AWS_PROFILE=$argv
            '';
          };
          k = {
            wraps = "kubectl";
            body = "${kubecolor} $argv";
          };
          kcx = {
            wraps = "kubectl config use-context";
            body = "${kubecolor} config use-context $argv";
          };
          mapscii = "${telnet} mapscii.me";
          mergekconf = ''
            function mergekconf -d "Merge multiple kubeconfig files into one"
              set -l kube_dir "$HOME/.kube"
              if not test -d "$kube_dir"
                  echo "Directory not found: $kube_dir"
                  return 1
              end

              set -l files_to_merge (find "$kube_dir" -type f -not -name "config" -not -path "*/cache/*")
              set -l all_configs "$kube_dir/config"

              for file in $files_to_merge
                  set all_configs "$all_configs:$file"
              end
              set -gx KUBECONFIG "$all_configs"

              echo "Merging kubeconfigs into $kube_dir/config"
              if ${kubectl} config view --flatten > "$kube_dir/config.tmp"
                  mv "$kube_dir/config" $HOME/.oldkubeconf-$(date +%Y-%m-%d_%H-%M-%S)
                  mv "$kube_dir/config.tmp" "$kube_dir/config"
                  echo "Successfully merged kubeconfigs."
              else
                  echo "Failed to merge kubeconfigs."
                  rm -f "$kube_dir/config.tmp"
                  return 1
              end

              for file in $files_to_merge
                if [ ! -z "$(cat $file | grep apiVersion)" ]
                   rm -f "$file"
                end
              end
              set -gx KUBECONFIG "$kube_dir/config"
            end
          '';
          nvim2 = "${neovide} $argv &; disown";
          shell = "nix shell nixpkgs#$argv";
          neval = "nix eval --raw --impure --expr \"with import <nixpkgs> {}; lib.getExe pkgs.$argv\"";
          nevalp = "nix eval nixpkgs#$argv.outPath";
          nevalcd = "cd $(nix eval --raw nixpkgs#$argv.outPath)";
          workmode = ''
            set mode (test (count $argv) -gt 0; and echo $argv[1])
            if [ "$fish_history" = "work" -a "$mode" != "false" ]
              return
            end
            function _tide_item_workmode
              _tide_print_item workmode $tide_workmode_icon' ' "WorkMode"
            end
            set -Ux tide_workmode_icon ""
            set -Ux tide_workmode_color 00BBFF
            funcsave --quiet _tide_item_workmode

            if [ "$mode" = "true" ]
              set -Ux default_left_prompt_items $tide_left_prompt_items
              set -Up tide_left_prompt_items workmode
              alias --save ssh="ssh -i ${home}/.ssh/id_ed25519_work" &>/dev/null
              alias --save scp="scp -i ${home}/.ssh/id_ed25519_work" &>/dev/null
              set -Ux GIT_SSH_COMMAND "ssh -i ${home}/.ssh/id_ed25519_work"
              set -Ux fish_history "work"
              tide reload
            else
              set -Ux tide_left_prompt_items $default_left_prompt_items
              functions --erase ssh 2>/dev/null; and functions --erase scp 2>/dev/null
              set -Ue GIT_SSH_COMMAND
              set -Ux fish_history "fish"
              tide reload
            end
          '';
        };
        generateCompletions = false;
        plugins = [
          {
            name = "nvm";
            src = pkgs.fetchFromGitHub {
              owner = "jorgebucaran";
              repo = "nvm.fish";
              rev = "2.2.17";
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
          a = lib.getExe' ansible "ansible";
          ap = "clear; ${lib.getExe' ansible "ansible-playbook"}";
          ktl = kubetail;

          #~ System
          cp = "cp -i";
          crontab = "crontab -i";
          ls = lsd;
          mv = "mv -i";
          rm = "rm -i";
          srm = "${trash} -i";
          sysclean = "flatpak remove --unused && nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
          sysdup = "nix-channel --update && sudo nix-channel --update && flatpak update && sudo nixos-rebuild switch --flake ${home}/Projects/000_myprojects/dotfiles.nix#${flakeName} --upgrade";

          #~ Git
          gita = "${git} add -A";
          gitb = "${git} branch";
          gitc = "${git} clone";
          gitca = "${git} commit -a";
          gitcm = "${git} commit -m";
          gitch = "${git} checkout";
          gitp = "${git} push";
          gitpp = "${git} pull";

          #~ Utilities
          aie = "${gh} copilot explain";
          ais = "${gh} copilot suggest";
          ff = "${fastfetch}";
          passgen = "cat /dev/urandom | tr -dc [:alnum:] | head -c";
          tldr = "${cht_sh}";
          tmp = "cd ~/.tmp";
          yt-album = "${yt_dlp} --config-locations ${home}/.config/yt-dlp/music -o \"${home}/Music/Albums/%(album)s - %(artist)s/%(playlist_autonumber)02d - %(track)s.%(ext)s\"";
          yt-music = "${yt_dlp} --config-locations ${home}/.config/yt-dlp/music -o \"${home}/Music/Artists/%(artist)s/%(album)s/%(title)s.%(ext)s\"";
        };
        shellInit = ''
          #################################################
          #### Fish Variables
          #################################################
          set fish_greeting ""
          export TERM="xterm-256color"

          #################################################
          #### Home specific fish variables
          #################################################
          export PATH="${home}/.local/share/JetBrains/Toolbox/scripts:${home}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:${home}/.nix-profile/sbin:${home}/.nix-profile/bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:${home}/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:/opt/homebrew/bin:$PATH";
          export XDG_DATA_DIRS="${home}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${home}/.local/share:/usr/local/share:/usr/share:${home}/.nix-profile/share:$XDG_DATA_DIRS";

          #################################################
          #### Applications
          #################################################
          #~ common ~#
          ${direnv} export fish | source
          ${helm} completion fish | source
          ${hugo} completion fish | source
          ${kubectl} completion fish | source

          #~ grc ~#
          for cmd in g++ gas head make ld ping6 tail traceroute6 $( ls ${grc}/share/grc/ | grep -vE 'jobs|systemctl' )
            set cmd "$(echo $cmd | sed 's/conf\.//g')"
            type "$cmd" >/dev/null 2>&1 && alias "$cmd"="${lib.getExe grc} --colour=auto $cmd"
          end
        '';
        loginShellInit = lib.mkIf (lib.hasSuffix "linux" system) ''
          if [ "$(tty)" = "/dev/tty1" ]
            export $(${pkgs.systemd}/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
            export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring
            export SSH_AUTH_SOCK=$GNOME_KEYRING_CONTROL/ssh
            ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
            if [ "${cfg.preferred.wm}" = "hyprland" ]
              XDG_CURRENT_DESKTOP=Hyprland Hyprland &>${home}/.cache/hyprland.log
            else
              XDG_CURRENT_DESKTOP=sway sway &>${home}/.cache/swaywm.log
            end
          end
        '';
      };
  };
}
