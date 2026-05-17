{ pkgs-unstable, ... }:

{
  programs.steam = {
    enable = true;
    extest.enable = true;
    extraCompatPackages = with pkgs-unstable; [
      proton-ge-bin
    ];
  };
}
