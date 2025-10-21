{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.nixos.mate-polkit;
in
{
  options.moduleopts.nixos.mate-polkit = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mate.mate-polkit.overrideAttrs {
        postInstall = ''
          sed -i '/OnlyShowIn/d' $out/etc/xdg/autostart/polkit-mate-authentication-agent-1.desktop
        '';
      };
      description = "Mate polkit package (modded to work with other environments)";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
