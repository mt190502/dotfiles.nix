{ lib, ... }:

{
  services.pipewire = {
    enable = lib.mkForce true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    wireplumber.enable = true;
  };
}
