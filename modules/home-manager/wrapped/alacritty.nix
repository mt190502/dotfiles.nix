{
  config,
  pkgs,
  ...
}:

with pkgs;
rec {
  name = "alacritty";
  original = alacritty;
  wrap = config.lib.nixGL.wrap original;
}
