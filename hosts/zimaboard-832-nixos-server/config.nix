{
  stateVersion = "25.11";
  platform = "nixos";
  arch = "x86_64-linux";
  primaryUser = "srvadmin";
  users = [
    "srvadmin"
  ];
  modules = [
    "clevis"
    "initrd-tools"
    "lanzaboote"
    "syncthing"
  ];
  profiles = [
    "k3s"
  ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = _: { };
}
