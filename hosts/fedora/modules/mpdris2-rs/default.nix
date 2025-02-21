{
  config,
  lib,
  pkgs,
  ...
}:

let
  mpdris2-rs = (
    pkgs.rustPlatform.buildRustPackage rec {
      pname = "mpdris2-rs";
      version = "1.0.0-beta.1";
      src = pkgs.fetchFromGitHub {
        owner = "szclsya";
        repo = pname;
        rev = version;
        sha256 = "sha256-c9CI5KaC9wyfnYUvAIdq/4fznb7ehe5qbUiQ9ooPG+M=";
      };
      useFetchCargoVendor = true;
      cargoHash = "sha256-Lbs94OSyLd4hGMUeDGbjaLstd7ACfE7Tbrbz3uAyKoY=";
      meta = {
        description = "MPRIS2 client for MPD written in Rust";
        homepage = "https://github.com/szclsya/mpdris2-rs";
      };
    }
  );
in
{
  options.pkgconfig.mpdris2-rs = {
    enable = lib.mkEnableOption "mpdrid2-rs";
  };
  config = lib.mkIf config.pkgconfig.mpdris2-rs.enable {
    home.packages = [
      mpdris2-rs
    ];
    systemd.user.services.mpdris2-rs = {
      Unit = {
        Description = "Music Player Daemon D-Bus Bridge";
        Wants = "mpd.service";
        After = "mpd.service";
      };

      Service = {
        Restart = "on-failure";
        ExecStart = "${mpdris2-rs}/bin/mpdris2-rs";
        BusName = "org.mpris.MediaPlayer2.mpd";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
