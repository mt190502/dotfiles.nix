{ lib, ... }:

let
  loadUser = user: _: {
    darwin = if builtins.pathExists ./${user}/darwin.nix then import ./${user}/darwin.nix else { };
    home = if builtins.pathExists ./${user}/home.nix then import ./${user}/home.nix else { };
    nixos = if builtins.pathExists ./${user}/nixos.nix then import ./${user}/nixos.nix else { };
  };

  users = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
in
{
  flake.users = lib.mapAttrs loadUser users;
}
