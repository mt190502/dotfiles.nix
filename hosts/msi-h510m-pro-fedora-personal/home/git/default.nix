{ lib, ... }:

{
  programs.git.settings.gpg."ssh".program = lib.mkForce "/opt/1Password/op-ssh-sign";
}
