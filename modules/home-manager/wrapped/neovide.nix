{
  config,
  pkgs,
  ...
}:

with pkgs;
rec {
  name = "neovide";
  original = neovide;
  wrap = config.lib.nixGL.wrap original;
}
