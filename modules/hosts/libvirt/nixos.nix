{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.nixos.fontconfig;
in
{
  config = lib.mkIf cfg.enable {
    programs.virt-manager = {
      enable = true;
      package = pkgs.virt-manager.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ pkgs.libayatana-appindicator ];
      });
    };
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
