{
  stateVersion = 6;
  platform = "darwin";
  arch = "aarch64-darwin";
  primaryUser = "taha";
  users = [ "taha" ];
  modules = [
    "docker"
    "fontconfig"
    "homebrew"
    "sops"
  ];
  profiles = [ ];
  packages = [ "ubuntu-fonts-google" ];
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  extraConfig = { ... }: { };
}
