{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.username = "fedora";
  home.homeDirectory = "/home/fedora";
  nixpkgs.config.allowUnfree = true;
  nixGL.packages = inputs.nixgl.packages;
  wrapped.mode = "nixGL";

  ########################################
  #
  ## Packages
  #
  ########################################
  #~ home.packages ~#
  home.packages = [
    config.wrapped.alacritty
    config.wrapped.dolphin
    config.wrapped.flameshot
    config.wrapped.imagemagick
    config.wrapped.jetbrains-toolbox
    config.wrapped.nwg-displays
    config.wrapped.qt5ct
    config.wrapped.qt6ct
    config.wrapped.universal-android-debloater
    config.wrapped.vscode
  ];

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  #~ custom modules ~#
  moduleopts.home-manager = {
    flatpak.enable = true;
    fontconfig.enable = true;
    gnome-keyring.enable = false; # I'm using keyring in system because of pam issues
    gtk.enable = true;
    prefered-wm = "sway";
    prefered-lock-app = "swaylock";
    kde.enable = true;
    onepassword-integration.enable = true;
    qt.enable = true;
    rnnoise-denoising.enable = true;
  };

  #~ systemd ~#
  xdg.configFile."user-tmpfiles.d/home-manager.conf" = {
    text = ''
      L %t/discord-ipc-0 - - - - .flatpak/dev.vencord.Vesktop/xdg-run/discord-ipc-0
      L %t/app/com.discordapp.Discord/discord-ipc-0 - - - - %t/.flatpak/dev.vencord.Vesktop/xdg-run/discord-ipc-0
    '';
    onChange = "${pkgs.systemd}/bin/systemd-tmpfiles --user --create";
  };

  ########################################
  #
  ## Custom Modules
  #
  ########################################
  imports = lib.map (p: ./. + "/${p}") (
    builtins.filter (p: !(p == "default.nix" || lib.hasSuffix ".txt" p)) (
      lib.attrNames (builtins.readDir ./.)
    )
  );
}
