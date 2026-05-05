rec {
  all = taha ++ berry ++ rose;
  ########################################
  #
  ## User SSH keys
  #
  ########################################
  taha = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVyQNBWyCGvlRlqEh/3Ga6CDF01MZo6Jj15mjqHzPFD fedora@190502"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG9M9x2OTAF1DdmENjb9p+MFgp5cZgwr9QR3JKc1rlW taha@thinkpad-190502"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmkUvMmx4scwZkRgOQqcqMorm8zLuqXK3HUYbsunrpl taha@macbook-190502"
  ];
  berry = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrXFgH/6r4is3eKX/URrmy46VbpNZeU50c0CC+iRUYF berry@raspberry-190502"
  ];
  rose = [ ];
}
