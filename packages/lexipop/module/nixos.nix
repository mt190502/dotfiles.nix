{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.lexipop.pointerAccess;

  # Home-manager users that opted in through programs.lexipop.pointerClicks.
  # The option may be absent (older home module), so read it defensively.
  homeUsers = config.home-manager.users or { };
  autoUsers = lib.filterAttrs (_: user: user.programs.lexipop.pointerClicks or false) homeUsers;
in
{
  options.programs.lexipop.pointerAccess = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = autoUsers != { };
      description = ''
        Grant the configured users read access to pointing devices (mice,
        touchpads, pointing sticks) so lexipop can dismiss its popup on any
        real left-click. Enabled automatically when a home-manager user sets
        programs.lexipop.pointerClicks.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "lexipop";
      description = "Group that owns the pointing devices handed to lexipop.";
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtins.attrNames autoUsers;
      example = lib.literalExpression ''[ "taha" ]'';
      description = "Users added to the pointing-device group.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };

    users.users = lib.genAttrs cfg.users (_: {
      extraGroups = [ cfg.group ];
    });

    # Hand ONLY pointing devices to the group; keyboards stay root/input-only.
    # udev cannot OR different keys in one match, so one rule per key. Anything
    # that is a keyboard (ID_INPUT_KEYBOARD) is deliberately not matched, so
    # presses never become readable through this group.
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="input", ENV{ID_INPUT_MOUSE}=="1", GROUP="${cfg.group}", MODE="0660"
      ACTION=="add|change", SUBSYSTEM=="input", ENV{ID_INPUT_TOUCHPAD}=="1", GROUP="${cfg.group}", MODE="0660"
      ACTION=="add|change", SUBSYSTEM=="input", ENV{ID_INPUT_POINTINGSTICK}=="1", GROUP="${cfg.group}", MODE="0660"
    '';
  };
}
