{
  config,
  flakeName,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
  programs.fish.shellAliases = {
    sysdup = lib.mkOverride 500 "nix-channel --update && sudo nix-channel --update && ${lib.getExe' pkgs.flatpak "flatpak"} update && sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/.config/dotfiles.nix#${flakeName} --upgrade";
    sysclean = lib.mkOverride 500 "${lib.getExe' pkgs.flatpak "flatpak"} remove --unused && nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    rebuild = lib.mkOverride 500 "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/.config/dotfiles.nix#${flakeName}";
  };
  services.flatpak = {
    enable = true;
    packages = [
      "ca.desrt.dconf-editor"
      "ch.openboard.OpenBoard"
      "com.belmoussaoui.ashpd.demo"
      "com.github.d4nj1.tlpui"
      "com.github.libresprite.LibreSprite"
      "com.github.tchx84.Flatseal"
      "com.obsproject.Studio"
      "com.parsecgaming.parsec"
      "com.slack.Slack"
      "com.stremio.Stremio"
      "com.usebottles.bottles"
      "com.valvesoftware.Steam"
      "fr.handbrake.ghb"
      "fr.romainvigier.MetadataCleaner"
      "io.github._0xzer0x.qurancompanion"
      "io.github.ungoogled_software.ungoogled_chromium"
      "io.gitlab.news_flash.NewsFlash"
      "md.obsidian.Obsidian"
      "me.timschneeberger.GalaxyBudsClient"
      "net.ankiweb.Anki"
      "net.davidotek.pupgui2"
      "org.audacityteam.Audacity"
      "org.equicord.equibop"
      "org.filezillaproject.Filezilla"
      "org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08"
      "org.gimp.GIMP"
      "org.gnome.Calculator"
      "org.gnome.Evolution"
      "org.gnome.Evolution.Extension.evolution-etesync"
      "org.gnome.FileRoller"
      "org.gnome.Loupe"
      "org.gnome.seahorse.Application"
      "org.gnome.TextEditor"
      "org.gtk.Gtk3theme.adw-gtk3-dark"
      "org.gtk.Gtk3theme.adw-gtk3"
      "org.kde.ark"
      "org.kde.kdenlive"
      "org.kde.krita"
      "org.kde.kruler"
      "org.kde.KStyle.Adwaita/x86_64/6.9"
      "org.kde.KStyle.Adwaita/x86_64/5.15-24.08"
      "org.kde.KStyle.Kvantum/x86_64/6.6"
      "org.kde.KStyle.Kvantum/x86_64/5.15"
      "org.kde.okular"
      "org.libreoffice.LibreOffice"
      "org.musicbrainz.Picard"
      "org.onlyoffice.desktopeditors"
      "org.prismlauncher.PrismLauncher"
      "org.qbittorrent.qBittorrent"
      "org.remmina.Remmina"
      "org.signal.Signal"
      "org.supertuxproject.SuperTux"
      "org.telegram.desktop"
      "org.texstudio.TeXstudio"
      "org.upscayl.Upscayl"
    ];
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
        args = "--user --prio=5";
      }
      {
        name = "fedora";
        location = "oci+https://registry.fedoraproject.org";
        args = "--user --prio=4";
      }
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
        args = "--user --prio=3";
      }
      {
        name = "fedora-testing";
        location = "oci+https://registry.fedoraproject.org#testing";
        args = "--user --prio=2";
      }
      {
        name = "gnome-nightly";
        location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
        args = "--user --prio=1";
      }
    ];
  };
  #########################################################################################################
  ### NOTE: You need to create file /etc/1password/custom_allowed_browsers with the following content:  ###
  ### librewolf                                                                                         ###
  ### flatpak-session-helper                                                                            ###
  #########################################################################################################
  home.file.".var/app/io.gitlab.librewolf-community/.librewolf/native-messaging-hosts/com.1password.1password.json".text =
    ''
      {
        "name": "com.1password.1password",
        "description": "1Password BrowserSupport",
        "path": "${config.home.homeDirectory}/.var/app/io.gitlab.librewolf-community/data/bin/1password-wrapper.sh",
        "type": "stdio",
        "allowed_extensions": [
          "{0a75d802-9aed-41e7-8daa-24c067386e82}",
          "{25fc87fa-4d31-4fee-b5c1-c32a7844c063}",
          "{d634138d-c276-4fc8-924b-40a0ea21d284}"
        ]
      }
    '';
  home.file.".var/app/io.gitlab.librewolf-community/data/bin/1password-wrapper.sh" = {
    text = ''
      #!/bin/sh
      exec flatpak-spawn --host /opt/1Password/1Password-BrowserSupport "$@"
    '';
    executable = true;
  };
}
