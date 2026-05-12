{ lib, ... }:

{
  programs.git.settings = lib.mkForce rec {
    user.signingKey = signing.key;
    signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmkUvMmx4scwZkRgOQqcqMorm8zLuqXK3HUYbsunrpl";
    gpg."ssh".program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };
}
