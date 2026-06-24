{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.gpu-screen-recorder.ui;
  package = cfg.package.override {
    inherit (config.security) wrapperDir;
    gpu-screen-recorder-notification = cfg.notificationPackage;
  };
in
{
  options = {
    programs.gpu-screen-recorder.ui = {
      package = lib.mkOption {
        default = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder-ui;
      };
      notificationPackage = lib.mkOption {
        default = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder-notification;
      };
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to install gpu-screen-recorder-ui and generate setcap
          wrappers for promptless recording.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security.wrappers."gsr-global-hotkeys" = {
      owner = "root";
      group = "root";
      capabilities = "cap_setuid+ep";
      source = "${package}/bin/gsr-global-hotkeys";
    };
    environment.systemPackages = [
      package
      cfg.notificationPackage
    ];
    systemd.packages = [ package ];
  };
}
