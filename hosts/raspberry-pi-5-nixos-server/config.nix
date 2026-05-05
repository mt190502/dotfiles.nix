{
  stateVersion = "25.11";
  platform = "rpi";
  arch = "aarch64-linux";
  primaryUser = "berry";
  users = [ "berry" ];
  modules = [
    "docker"
    "sops"
  ];
  profiles = [ "raspberrypi" ];
  packages = [ ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = _: { };
}
