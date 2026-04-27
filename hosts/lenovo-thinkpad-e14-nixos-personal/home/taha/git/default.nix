{ osConfig, lib, ... }:

{
  programs.git.signing.signer = lib.getExe' osConfig.programs._1password-gui.package "op-ssh-sign";
}
