{
  stateVersion = "25.11";
  platform = "nixos";
  arch = "x86_64-linux";
  users = [
    "taha"
    "rose"
  ];
  modules = [
    "clevis"
    "docker"
    "evolution"
    "fontconfig"
    "gpu-screen-recorder"
    "initrd-tools"
    "lanzaboote"
    "libvirt"
    "mate-polkit"
    "onepassword"
    "pipewire"
    "plasma"
    "printer"
    "steam"
    "tlp"
    "waydroid"
  ];
  profiles = [ "extra" ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = _: { };
}
