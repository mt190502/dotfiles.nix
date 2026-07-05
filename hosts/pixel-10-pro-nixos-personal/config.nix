{
  stateVersion = "26.05";
  platform = "avf";
  arch = "aarch64-linux";
  primaryUser = "droid";
  users = [ "droid" ];
  modules = [
    "resolved"
    "tailscale"
  ];
  profiles = [ ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = _: { };
}
