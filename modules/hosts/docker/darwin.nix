{ config, lib, ... }:

let
  cfg = config.moduleopts.darwin;
in
{
  config = lib.mkIf (cfg.docker.enable && cfg.homebrew.enable) {
    homebrew.casks = [ "docker-desktop" ];
  };
}
