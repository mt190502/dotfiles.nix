{
  stateVersion = "25.11";
  platform = "nixos";
  arch = "x86_64-linux";
  users = [ "taha" "rose" ];
  modules = [
    "docker"
    "fontconfig"
    "lanzaboote"
    "libvirt"
    "mate-polkit"
    "onepassword"
    "pipewire"
    "plasma"
    "printer"
    "tailscale"
    "tlp"
  ];
  profiles = [ "extra" ];
  packages = [
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
