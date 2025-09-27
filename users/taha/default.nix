{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

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
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    users.taha = import ./home;
  };
}
