{
  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
      "ssh"
    ];
  };
  xdg.dataFile."dbus-1/services/org.kde.secretservicecompat.service".text = ''
    [D-BUS Service]
    Name=org.kde.secretservicecompat
    Exec=/bin/false
  '';
}
