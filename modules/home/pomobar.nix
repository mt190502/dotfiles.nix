{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) concatStringsSep mkEnableOption;
  inherit (pkgs) fetchFromGitHub stdenv;

  cfg = config.services.pomobar;
  package = stdenv.mkDerivation rec {
    pname = "pomobar";
    version = "main";
    src = fetchFromGitHub {
      owner = "mt190502";
      repo = pname;
      rev = "8888b17";
      sha256 = "sha256-efsYJx4UwkE0rkhScxgidlD+rMh+PgIb07UHj+Haapo=";
    };
    nativeBuildInputs = with pkgs; [
      gcc
      gnumake
    ];
    installPhase = ''
      mkdir -p $out/bin
      make
      cp pomobar-server pomobar-client $out/bin/
      chmod +x $out/bin/pomobar-server
      chmod +x $out/bin/pomobar-client
    '';
    meta = with lib; {
      description = "A waybar compatible pomodoro timer (W.I.P.)";
      homepage = "https://github.com/mt190502/pomobar";
      license = licenses.gpl3;
    };
  };
in
{
  options.services.pomobar = {
    enable = mkEnableOption "Enable pomobar service";
    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = "The pomobar package to use.";
    };
    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra arguments to pass to the pomobar executable.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    systemd.user.services.pomobar = {
      Unit = {
        Description = "Pomodoro timer";
        Wants = "waybar.service";
        After = "waybar.service";
      };
      Service = {
        Restart = "on-failure";
        ExecStart = "${lib.getExe' package "pomobar-server"} ${concatStringsSep " " cfg.extraArgs}";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
