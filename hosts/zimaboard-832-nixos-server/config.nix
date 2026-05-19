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
    "lanzaboote"
    "printer"
    "syncthing"
  ];
  profiles = [
    "k3s"
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
