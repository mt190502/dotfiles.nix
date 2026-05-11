rec {
  all = taha ++ srvadmin ++ rose;
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
  srvadmin = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuN2b//3ffdHbAFvrAJcbBv4Q2AXtAqL8y/eB1NDgDB srvadmin@raspberry-190502"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYBkNk+vJuYEqXJIi5ut7h5oxmxclDZSW73OxaqcU+a srvadmin@zimaboard-190502"
  ];
  rose = [ ];
}
