{ config, ... }:

{
  programs.swappy = {
    enable = true;
    settings = {
      Default = {
        save_dir = "${config.home.homeDirectory}/Pictures/Screenshots/";
      };
    };
  };
}
