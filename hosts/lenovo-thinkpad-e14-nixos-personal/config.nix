{
  stateVersion = "25.11";
  platform = "nixos";
  arch = "x86_64-linux";
  users = [ "taha" ];
  modules = [
    "docker"
    "fontconfig"
    "lanzaboote"
    "libvirt"
    "mate-polkit"
    "onepassword"
    "pipewire"
    "printer"
    "tailscale"
    "tlp"
  ];
  profiles = [ "extra" ];
  packages = [
    "recidia"
    "ubuntu-fonts-google"
  ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = { ... }: { };
}
