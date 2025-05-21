{ pkgs, inputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.default ];
  users = {
    mutableUsers = true;
    users.taha = {
      isNormalUser = true;
      extraGroups = [
        "audio"
        "kvm"
        "libvirtd"
        "networkmanager"
        "qemu"
        "video"
        "wheel"
      ];
      shell = pkgs.fish;
    };
  };
  programs.fish.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
    };
    users.taha = import ./home;
  };
}
