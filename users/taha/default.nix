{
  inputs,
  flakeName,
  system,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  user = {
    shell = pkgs.fish;
  };

  home = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit
        inputs
        flakeName
        system
        pkgs-unstable
        ;
    };
  };

  entry =
    if lib.hasSuffix "darwin" system then
      {
        users.users.taha = user // {
          home = "/Users/taha";
          uid = 502;
        };
        home-manager = home // {
          users.taha = import ./darwin.nix;
        };
      }
    else
      {
        users = {
          mutableUsers = true;
          users.taha = user // {
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
          };
        };
        home-manager = home // {
          users.taha = import ./linux.nix;
        };
      };
in
entry
