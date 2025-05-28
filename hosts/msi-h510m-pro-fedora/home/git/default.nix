{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.git;
in
{
  config = lib.mkIf cfg.enable {
    programs.git.signing.signer = "/opt/1Password/op-ssh-sign";
  };
}
