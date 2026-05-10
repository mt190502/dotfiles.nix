{
  stateVersion = "25.11";
  platform = "rpi";
  arch = "aarch64-linux";
  primaryUser = "srvadmin";
  users = [ "srvadmin" ];
  modules = [
    "docker"
    "sops"
    "tailscale"
    "tang"
  ];
  profiles = [
    "k3s"
    "raspberrypi"
  ];
  packages = [ ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = _: { };
}
