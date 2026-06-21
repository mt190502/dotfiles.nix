{
  config,
  flakeName,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) getExe getExe';
  fastfetch = getExe config.programs.fastfetch.package;
  gh = getExe pkgs.gh;
  git = getExe pkgs.git;
  grc = getExe pkgs.grc;
  hugo = getExe pkgs.hugo;
  lsd = getExe pkgs.lsd;
  telnet = getExe' pkgs.inetutils "telnet";
  trash = getExe' pkgs.trash-cli "trash";
  yt-dlp = getExe pkgs.yt-dlp;
  home = config.home.homeDirectory;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  rebuildCmd = if isDarwin then "darwin-rebuild" else "nixos-rebuild";
in
{
  programs.fish = {
    enable = true;
    functions = {
      cd = ''
        builtin cd $argv
        if status is-interactive
          ${lsd}
        end
      '';
      mapscii = "${telnet} mapscii.me";
      shell = "nix shell nixpkgs#$argv";
      neval = "nix eval --raw --impure --expr \"with import <nixpkgs> {}; lib.getExe pkgs.$argv\"";
      nevalp = "nix eval nixpkgs#$argv.outPath";
      nevalcd = "cd $(nix eval --raw nixpkgs#$argv.outPath)";
      _rebuilddiff = ''
        set -l oldsys /run/current-system
        set -l newsys $argv[1]
        if test -z "$newsys"
          echo "No system path provided"
          return 1
        end

        echo "Diffing $oldsys -> $newsys"
        echo ""

        echo "=== nvd version diff ==="
        ${getExe pkgs.nvd} diff $oldsys $newsys 2>/dev/null
        echo ""

        echo "=== Closure diff ==="
        nix store diff-closures $oldsys $newsys 2>/dev/null
        echo ""

        echo "=== New/removed files in /etc (non-hash) ==="
        diff -rq $oldsys/etc $newsys/etc 2>/dev/null | grep -vE 'cachedir|nix/store' | head -40
        echo ""

        echo "=== Changed systemd units ==="
        diff -rq $oldsys/etc/systemd $newsys/etc/systemd 2>/dev/null | grep -E 'home-manager|\.service$' | head -20
        echo ""

        set -l old_hm (grep -oP '/nix/store/[a-z0-9]+-home-manager-generation' $oldsys/etc/systemd/system/home-manager-*.service 2>/dev/null | head -1)
        set -l new_hm (grep -oP '/nix/store/[a-z0-9]+-home-manager-generation' $newsys/etc/systemd/system/home-manager-*.service 2>/dev/null | head -1)
        if test -n "$old_hm" -a -n "$new_hm" -a "$old_hm" != "$new_hm"
          echo "=== Home-manager files diff ==="
          diff -rq $old_hm/home-files $new_hm/home-files 2>/dev/null | head -40
          echo ""
        end
      '';
      rebuild = ''
        set -l flake "${home}/.config/dotfiles.nix"
        set -l cmd ${flakeName}
        set -l dry_run false
        for arg in $argv
          switch $arg
            case --dry-run
              set dry_run true
          end
        end

        echo "Building $cmd..."
        sudo ${rebuildCmd} build --flake $flake#$cmd
        if test $status -ne 0
          return 1
        end
        echo ""

        set -l newsys (readlink -f result)
        _rebuilddiff $newsys
        rm -f result

        if test "$dry_run" = true
          return
        end

        read -P "Switch to new configuration? [y/N] " confirm
        if test "$confirm" = "y" -o "$confirm" = "Y"
          sudo ${rebuildCmd} switch --flake $flake#$cmd
        else
          echo "Aborted."
        end
      '';
      sysdup = ''
        set -l flake "${home}/.config/dotfiles.nix"
        set -l cmd ${flakeName}
        set -l dry_run false
        for arg in $argv
          switch $arg
            case --dry-run
              set dry_run true
          end
        end

        echo "Updating channels and flake inputs..."
        nix-channel --update && sudo nix-channel --update
        nix flake update --flake $flake
        echo ""

        echo "Building $cmd..."
        sudo ${rebuildCmd} build --flake $flake#$cmd
        if test $status -ne 0
          return 1
        end
        echo ""

        set -l newsys (readlink -f result)
        _rebuilddiff $newsys
        rm -f result

        if test "$dry_run" = true
          return
        end

        read -P "Switch to new configuration? [y/N] " confirm
        if test "$confirm" = "y" -o "$confirm" = "Y"
          sudo ${rebuildCmd} switch --flake $flake#$cmd
        else
          echo "Aborted."
        end
      '';
      watchdiff = ''
        if test (count $argv) -lt 1
          echo "Usage: watchdiff <command>"
          return 1
        end

        set targetfile $argv[1]
        if not test -f $targetfile
          echo "File $targetfile does not exist."
          return 1
        end

        set oldfile_tmp (mktemp)
        cat $targetfile > $oldfile_tmp
        echo "Watching $targetfile for changes. Press Ctrl+C to stop."
        while true
          ${lib.getExe' pkgs.fswatch "fswatch"} --event Modified --one-event $targetfile >/dev/null
          set newfile_tmp (mktemp)
          cat $targetfile > $newfile_tmp
          clear

          echo "=== "(date)" ==="
          echo ""
          ${lib.getExe' pkgs.diffutils "diff"} --color=always -u $oldfile_tmp $newfile_tmp

          rm -f $oldfile_tmp
          set oldfile_tmp $newfile_tmp
        end
      '';
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
          rev = "4.4.8";
          sha256 = "sha256-Sf671UGOQXtOMrqoEOIBG5TCt0p5fd+aKGF2ExImbbs=";
        };
      }
    ];
    shellAliases = {
      #~ System
      cp = "cp -i";
      crontab = "crontab -i";
      ls = lsd;
      lsgens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | sort -r";
      mv = "mv -i";
      rm = "rm -i";
      srm = "${trash} -i";
      sysclean = lib.mkDefault (
        if isDarwin then
          "nix-collect-garbage -d"
        else
          "nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot"
      );

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

      tmp = "cd ~/.tmp";
      yt-album = "${yt-dlp} --config-locations ${home}/.config/yt-dlp/music -o \"${home}/Music/Albums/%(album)s - %(artist)s/%(playlist_autonumber)02d - %(track)s.%(ext)s\"";
      yt-music = "${yt-dlp} --config-locations ${home}/.config/yt-dlp/music -o \"${home}/Music/Artists/%(artist)s/%(album)s/%(title)s.%(ext)s\"";
    }
    // lib.optionalAttrs (!lib.hasSuffix "server" flakeName) {
      tldr = "${getExe pkgs.cht-sh}";
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
      ${hugo} completion fish | source

      #~ grc ~#
      for cmd in g++ gas head make ld ping6 tail traceroute6 $( ls ${pkgs.grc}/share/grc/ | grep -vE 'jobs|systemctl' )
        set cmd "$(echo $cmd | sed 's/conf\.//g')"
        type "$cmd" >/dev/null 2>&1 && alias "$cmd"="${grc} --colour=auto $cmd"
      end
    '';
    loginShellInit = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
      ''
        if [ "$(tty)" = "/dev/tty1" ]
          export $(${pkgs.systemd}/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
          export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring
          export SSH_AUTH_SOCK=$GNOME_KEYRING_CONTROL/ssh
          ${getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all
      ''
      + (
        if (config.preferences.desktopenv == "sway") then
          ''
            XDG_CURRENT_DESKTOP=sway sway &>${home}/.cache/swaywm.log
          ''
        else if (config.preferences.desktopenv == "plasma") then
          ''
            XDG_CURRENT_DESKTOP=KDE startplasma-wayland &>${home}/.cache/plasma.log
          ''
        else
          ''
            echo "No WM set in preferences, skipping session start" >&2
          ''
      )
      + ''
        end
      ''
    );
  };
}
