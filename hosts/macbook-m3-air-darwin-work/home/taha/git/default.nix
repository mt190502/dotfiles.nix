{ lib, ... }:

{
  programs.git.settings = {
    signing.key = lib.mkForce "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmkUvMmx4scwZkRgOQqcqMorm8zLuqXK3HUYbsunrpl";
    gpg."ssh".program = lib.mkForce "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };
}
