let
  matchHost =
    hostName: patterns:
    builtins.any (
      pat: builtins.match (builtins.replaceStrings [ "*" ] [ ".*" ] pat) hostName != null
    ) patterns;
  shouldInclude =
    flakeName: _: cfg:
    let
      hosts = cfg.hosts or [ ];
      excludeHosts = cfg.excludeHosts or [ ];
      inHosts = hosts == [ ] || matchHost flakeName hosts;
      inExclude = matchHost flakeName excludeHosts;
    in
    inHosts && !inExclude;
  secretAttrs = [
    "type"
    "sopsFile"
    "sopsFormat"
    "source"
    "homeTarget"
    "globalTarget"
    "mode"
    "group"
    "restartUnits"
    "reloadUnits"
    "neededForUsers"
    "hosts"
    "excludeHosts"
  ];

  baseSecret =
    cfg:
    removeAttrs cfg secretAttrs
    // {
      inherit (cfg) sopsFile;
      format = cfg.sopsFormat;
    };
in
{
  inherit
    matchHost
    shouldInclude
    secretAttrs
    baseSecret
    ;
}
