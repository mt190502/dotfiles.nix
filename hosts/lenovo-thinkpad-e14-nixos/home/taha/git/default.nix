{
  config,
  lib,
  osConfig,
  ...
}:

let
  cfg = config.moduleopts.home-manager.git;
  onepass = osConfig.moduleopts.nixos.onepassword.package;
in
{
  config = lib.mkIf cfg.enable {
    programs.git.signing.signer = lib.getExe' onepass "op-ssh-sign";
  };
}
