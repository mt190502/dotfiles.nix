{ ... }:

{
  services.flatpak = {
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
}
