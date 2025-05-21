{ pkgs, ... }:

{
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-gmmlib
        intel-media-driver
        intel-ocl
        intel-vaapi-driver
        libva-vdpau-driver
      ];
    };
    intel-gpu-tools.enable = true;
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };
}
