{
  inputs,
  lib,
  ...
}:

let
  hosts = lib.filter (h: h != null) (
    map
      (
        name:
        let
          cfgPath = inputs.self + "/hosts/${name}/config.nix";
          netPath = inputs.self + "/hosts/${name}/host/networking/default.nix";
        in
        if !(builtins.pathExists cfgPath && builtins.pathExists netPath) then
          null
        else
          let
            hostCfg = import cfgPath;
            netMod = import netPath;
            netCfg = if builtins.isFunction netMod then netMod { inherit lib; } else netMod;
            hostName = netCfg.networking.hostName or null;
            user =
              hostCfg.primaryUser or (hostCfg.user
                or (if hostCfg ? users && hostCfg.users != [ ] then builtins.head hostCfg.users else null)
              );
          in
          if hostName == null || user == null then null else { inherit name hostName user; }
      )
      (
        lib.sort lib.lessThan (
          builtins.attrNames (
            lib.filterAttrs (_: t: t == "directory") (builtins.readDir (inputs.self + "/hosts"))
          )
        )
      )
  );
  hostMatchBlocks = lib.listToAttrs (
    map (h: {
      inherit (h) name;
      value = {
        inherit (h) user;
        hostname = h.hostName;
        forwardAgent = true;
      };
    }) hosts
  );
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = lib.mkDefault false;
    extraOptionOverrides = {
      "Include" = "overrides/*.conf";
    };
    settings = {
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
      };
    }
    // hostMatchBlocks;
  };
}
