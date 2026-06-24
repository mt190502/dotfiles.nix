{
  config,
  osConfig,
  lib,
  ...
}:

let
  cfg = osConfig.programs.gpu-screen-recorder.ui;
  package = cfg.package.override {
    inherit (osConfig.security) wrapperDir;
    gpu-screen-recorder-notification = cfg.notificationPackage;
  };

  valueType = lib.types.oneOf [
    lib.types.str
    lib.types.bool
    lib.types.int
    (lib.types.listOf (
      lib.types.oneOf [
        lib.types.str
        lib.types.bool
        lib.types.int
      ]
    ))
  ];

  toConfigValue =
    v:
    if v == true then
      "true"
    else if v == false then
      "false"
    else
      toString v;

  toConfig =
    settings:
    lib.concatStringsSep "\n" (
      lib.flatten (
        lib.mapAttrsToList (
          k: v:
          if builtins.isList v then map (x: "${k} ${toConfigValue x}") v else [ "${k} ${toConfigValue v}" ]
        ) settings
      )
    );
in
{
  options.programs.gpu-screen-recorder = {
    settings = lib.mkOption {
      type = lib.types.attrsOf valueType;
      default = { };
      description = ''
        gpu-screen-recorder settings written to
        `~/.config/gpu-screen-recorder/config`.
        Keys are dot-separated paths (e.g. `main.fps`).
        List values produce multiple lines with the same key.
      '';
    };
    ui = {
      systemd.target = lib.mkOption {
        type = lib.types.str;
        description = ''
          The systemd target that will automatically start the gsr-ui service.
        '';
        default = "graphical-session.target";
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf valueType;
        default = { };
        description = ''
          gpu-screen-recorder-ui settings written to
          `~/.config/gpu-screen-recorder/config_ui`.
          Keys are dot-separated paths (e.g. `main.fps`).
          List values produce multiple lines with the same key.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.gpu-screen-recorder-ui = {
      Unit = {
        Description = "GPU Screen Recorder UI daemon";
      };
      Service = {
        ExecStart = "${package}/bin/gsr-ui launch-daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ config.programs.gpu-screen-recorder.ui.systemd.target ];
      };
    };
    home.activation.gpuScreenRecorder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.xdg.configHome}/gpu-screen-recorder"
      cat >"${config.xdg.configHome}/gpu-screen-recorder/config" <<'EOF'
      ${toConfig config.programs.gpu-screen-recorder.settings}
      EOF
      cat >"${config.xdg.configHome}/gpu-screen-recorder/config_ui" <<'EOF'
      ${toConfig config.programs.gpu-screen-recorder.ui.settings}
      EOF
    '';
  };
}
