{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.moduleopts.flatpak;
in
{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  options.moduleopts.flatpak = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Flatpak";
    };
  };
  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      packages = [
        "ca.desrt.dconf-editor"
        "ch.openboard.OpenBoard"
        "com.belmoussaoui.ashpd.demo"
        "com.github.libresprite.LibreSprite"
        "com.github.tchx84.Flatseal"
        "com.mattjakeman.ExtensionManager"
        "com.obsproject.Studio"
        "com.stremio.Stremio"
        "com.usebottles.bottles"
        "com.valvesoftware.Steam"
        "com.vivaldi.Vivaldi"
        "dev.vencord.Vesktop"
        "fr.handbrake.ghb"
        "fr.romainvigier.MetadataCleaner"
        "io.bassi.Amberol"
        "io.github._0xzer0x.qurancompanion"
        "io.github.mrvladus.List"
        "io.github.ungoogled_software.ungoogled_chromium"
        "io.gitlab.librewolf-community"
        "md.obsidian.Obsidian"
        "net.ankiweb.Anki"
        "net.davidotek.pupgui2"
        "org.audacityteam.Audacity"
        "org.filezillaproject.Filezilla"
        "org.gimp.GIMP"
        "org.gnome.Calculator"
        "org.gnome.Calendar"
        "org.gnome.clocks"
        "org.gnome.Evolution"
        "org.gnome.FileRoller"
        "org.gnome.Loupe"
        "org.gnome.seahorse.Application"
        "org.gnome.TextEditor"
        "org.gtk.Gtk3theme.adw-gtk3-dark"
        "org.gtk.Gtk3theme.adw-gtk3"
        "org.inkscape.Inkscape"
        "org.kde.kdenlive"
        "org.kde.krita"
        "org.kde.kruler"
        "org.kde.KStyle.Kvantum/x86_64/5.15"
        "org.kde.KStyle.Kvantum/x86_64/6.6"
        "org.kde.okular"
        "org.libreoffice.LibreOffice"
        "org.mozilla.Thunderbird"
        "org.musicbrainz.Picard"
        "org.nicotine_plus.Nicotine"
        "org.onlyoffice.desktopeditors"
        "org.prismlauncher.PrismLauncher"
        "org.qbittorrent.qBittorrent"
        "org.remmina.Remmina"
        "org.signal.Signal"
        "org.telegram.desktop"
        "org.texstudio.TeXstudio"
        "org.upscayl.Upscayl"
      ];
      remotes = [
        {
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
          args = "--user --prio=6";
        }
        {
          name = "fedora";
          location = "oci+https://registry.fedoraproject.org";
          args = "--user --prio=5";
        }
        {
          name = "flathub-beta";
          location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
          args = "--user --prio=4";
        }
        {
          name = "fedora-testing";
          location = "oci+https://registry.fedoraproject.org#testing";
          args = "--user --prio=3";
        }
        {
          name = "gnome-nightly";
          location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
          args = "--user --prio=2";
        }
        # {
        #   name = "kdeapps";
        #   location = "https://distribute.kde.org/kdeapps.flatpakrepo";
        #   args = "--user --prio=1";
        # }
      ];
    };
  };
}
