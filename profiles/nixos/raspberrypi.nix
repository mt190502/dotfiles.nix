{ config, inputs, ... }:

{
  imports = with inputs.nixos-raspberrypi.nixosModules; [
    raspberry-pi-5.base
    raspberry-pi-5.bluetooth
    raspberry-pi-5.page-size-16k
    nixpkgs-rpi
  ];
  services.openssh.enable = true;
  system.nixos.tags =
    let
      cfg = config.boot.loader.raspberry-pi;
    in
    [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];
}
