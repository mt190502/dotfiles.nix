{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.fish;
  home = config.home.homeDirectory;
in
{
  options.moduleopts.fish = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "fish";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;

      functions = {
        cd = "builtin cd $argv; ${lib.getExe pkgs.lsd}";
        mapscii = "${pkgs.inetutils}/bin/telnet mapscii.me";
        nvim2 = "${lib.getExe config.wrapped.neovide} $argv &; disown";
        scrcpy-camera = "${lib.getExe pkgs.scrcpy} --camera-size=2560x1440 --video-codec=h265 --video-encoder=OMX.qcom.video.encoder.hevc --video-source=camera --no-audio --camera-id=1 --v4l2-sink=/dev/video0 --no-video-playback $argv";
        shell = "nix shell nixpkgs#$argv";
        neval = "nix eval --raw --impure --expr \"with import <nixpkgs> {}; lib.getExe pkgs.$argv\"";
        nevalp = "nix eval nixpkgs#$argv.outPath";
        nevalcd = "cd $(nix eval --raw nixpkgs#$argv.outPath)";
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
        a = "${pkgs.ansible}/bin/ansible";
        ap = "clear; ${pkgs.ansible}/bin/ansible-playbook";
        k = "${lib.getExe pkgs.kubectl}";

        #~ System
        cp = "cp -i";
        crontab = "crontab -i";
        ls = "${lib.getExe pkgs.lsd}";
        mv = "mv -i";
        rm = "rm -i";
        srm = "trash -i";

        #~ Git
        gita = "${lib.getExe pkgs.git} add -A";
        gitb = "${lib.getExe pkgs.git} branch";
        gitc = "${lib.getExe pkgs.git} clone";
        gitca = "${lib.getExe pkgs.git} commit -a";
        gitcm = "${lib.getExe pkgs.git} commit -m";
        gitch = "${lib.getExe pkgs.git} checkout";
        gitp = "${lib.getExe pkgs.git} push";
        gitpp = "${lib.getExe pkgs.git} pull";

        #~ Utilities
        aie = "${lib.getExe pkgs.gh} copilot explain";
        ais = "${lib.getExe pkgs.gh} copilot suggest";
        ff = "${lib.getExe pkgs.fastfetch}";
        passgen = "cat /dev/urandom | tr -dc [:alnum:] | head -c";
        tldr = "${lib.getExe pkgs.cht-sh}";
        tmp = "cd ~/.tmp";
        yt-album = "${lib.getExe pkgs.yt-dlp} -o \"${home}/Music/Albums/%(album)s - %(artist)s/%(playlist_autonumber)02d - %(track)s.%(ext)s\"";
        yt-music = "${lib.getExe pkgs.yt-dlp} -o \"${home}/Music/Artists/%(artist)s/%(album)s/%(title)s.%(ext)s\"";
      };

      shellInit = ''
        #################################################
        #### Fish Variables
        #################################################
        set fish_greeting ""
        export TERM="xterm-256color"

        #################################################
        #### Applications
        #################################################
        #~ common ~#
        ${lib.getExe pkgs.direnv} export fish | source
        ${lib.getExe pkgs.kubernetes-helm} completion fish | source
        ${lib.getExe pkgs.hugo} completion fish | source
        ${lib.getExe pkgs.kubectl} completion fish | source

        #~ grc ~#
        for cmd in g++ gas head make ld ping6 tail traceroute6 $( ls ${pkgs.grc}/share/grc/ | grep -vE 'jobs|systemctl' )
          set cmd "$(echo $cmd | sed 's/conf\.//g')"
          type "$cmd" >/dev/null 2>&1 && alias "$cmd"="${lib.getExe pkgs.grc} --colour=auto $cmd"
        end 
      '';
    };
  };
}
