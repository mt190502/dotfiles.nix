let
  userDirs = builtins.attrNames (builtins.readDir ./.);
  validUsers = builtins.filter (name: builtins.pathExists (./. + "/${name}/default.nix")) userDirs;
in
{
  home-manager.users = builtins.listToAttrs (
    builtins.map (name: {
      inherit name;
      value = import ./${name};
    }) validUsers
  );
}
