{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) concatStringsSep mkEnableOption;
  inherit (pkgs) rustPlatform fetchFromGitHub;

  cfg = config.services.mpdris2-rs;
  package = rustPlatform.buildRustPackage rec {
    pname = "mpdris2-rs";
    version = "v1.1.1";
    src = fetchFromGitHub {
      owner = "szclsya";
      repo = pname;
      rev = version;
      sha256 = "sha256-oiyqK7vj41d9bsXBtenc477SOrVHRkXpFljkN8MjdQg=";
    };
    cargoHash = "sha256-rA/za8fc2RiURaiijc49y+2QBcS6cDavZQFjVh+7Iow=";
    meta = {
      description = "MPRIS2 client for MPD written in Rust";
      homepage = "https://github.com/szclsya/mpdris2-rs";
      mainProgram = "mpdris2-rs";
    };
  };
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
