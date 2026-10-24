{ pkgs, ... }:

{
  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ pkgs.libayatana-appindicator ];
    });
  };
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };
  virtualisation.spiceUSBRedirection.enable = true;
}
