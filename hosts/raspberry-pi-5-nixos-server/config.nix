{
  stateVersion = "25.11";
  platform = "rpi";
  arch = "aarch64-linux";
  primaryUser = "srvadmin";
  users = [ "srvadmin" ];
  modules = [
    "docker"
    "initrd-tools"
  ];
  profiles = [
    "k3s"
    "raspberrypi"
  ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = _: { };
}
