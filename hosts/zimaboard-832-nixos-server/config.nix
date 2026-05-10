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
    "docker"
    "lanzaboote"
    "printer"
    "sops"
    "tailscale"
  ];
  profiles = [ ];
  packages = [ ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = _: { };
}
