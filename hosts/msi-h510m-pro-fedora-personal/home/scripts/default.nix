{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.file = builtins.listToAttrs (
    lib.map (path: {
      name = ".local/bin/${path}";
      value = {
        executable = true;
        source =
          let
            substitutions = lib.flatten (
              lib.mapAttrsToList
                (k: v: [
                  "--replace"
                  "@${k}@"
                  "${v}"
                ])
                {
                  inherit (config.bin) bash;
                }
            );
          in
          pkgs.substitute {
            src = ./scripts.d + "/${path}";
            inherit substitutions;
          };
      };
    }) (builtins.attrNames (builtins.readDir ./scripts.d))
  );
}
