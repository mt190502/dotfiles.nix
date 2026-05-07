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
  options.sharing.users = lib.mkOption {
    type = lib.types.attrs;
    description = "A set of users to share configurations for. Each user should have a directory with their name, and inside that directory, you can have darwin.nix, home.nix, and nixos.nix files for their respective configurations.";
    default = { };
  };
  config.sharing.users = lib.mapAttrs loadUser users;
}
