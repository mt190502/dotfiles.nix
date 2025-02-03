{ config, ... }:

{
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
      #exec flatpak-spawn --host ${config.home.homeDirectory}/.nix-profile/share/1password/1Password-BrowserSupport "$@"      #~ not work on home manager only setups
    '';
    executable = true;
  };
}
