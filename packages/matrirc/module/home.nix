{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  cfg = config.programs.matrirc;
  stateDir = "${config.home.homeDirectory}/.local/state/matrirc";
  execStart = lib.concatStringsSep " " (
    [
      (lib.getExe cfg.package)
      "--ircd-listen"
      (lib.escapeShellArg cfg.listenAddress)
      "--state-dir"
      (lib.escapeShellArg cfg.stateDir)
    ]
    ++ lib.optional cfg.allowRegister "--allow-register"
  );
in
{
  options.programs.matrirc = {
    enable = lib.mkEnableOption "matrirc, a local IRC gateway for Matrix";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../default.nix { inherit pkgs-unstable; };
      defaultText = lib.literalExpression "pkgs.callPackage ../default.nix { inherit pkgs-unstable; }";
      description = "The matrirc package.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:6667";
      description = "IRC listen address for Pidgin and other local IRC clients.";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = stateDir;
      defaultText = lib.literalExpression ''"\${config.home.homeDirectory}/.local/state/matrirc"'';
      description = "Directory containing the encrypted Matrix session and sync store.";
    };

    allowRegister = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow a new local IRC identity to initialize a Matrix session.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.matrirc = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "Local IRC gateway for Matrix";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = execStart;
        Restart = "on-failure";
        RestartSec = "3s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
