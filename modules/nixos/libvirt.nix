{ pkgs, ... }:

{
  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ pkgs.libayatana-appindicator ];
    });
  };
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
