{ lib, ... }:

{
  programs.git.settings.gpg."ssh".program = lib.mkForce "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
}
