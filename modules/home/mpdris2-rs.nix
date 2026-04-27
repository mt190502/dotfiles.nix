{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) concatStringsSep mkEnableOption;

  cfg = config.services.mpdris2-rs;
  package = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".mpdris2-rs;
in
{
  options.services.mpdris2-rs = {
    enable = mkEnableOption "Enable mpdris2-rs service";
    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = "The mpdris2-rs package to use.";
    };
    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra arguments to pass to the mpdris2-rs executable.";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.mpdris2-rs = {
      Unit = {
        Description = "Music Player Daemon D-Bus Bridge";
        Wants = "mpd.service";
        After = "mpd.service";
      };
      Service = {
        Type = "dbus";
        Restart = "on-failure";
        ExecStart = "${lib.getExe package} ${concatStringsSep " " cfg.extraArgs}";
        BusName = "org.mpris.MediaPlayer2.mpd";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
