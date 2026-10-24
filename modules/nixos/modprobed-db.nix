{ lib, pkgs, ... }:

let
  systemModprobedDb = pkgs.modprobed-db.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace ./common/modprobed-db.in \
        --replace 'XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-''$HOMEDIR/.config}"' 'XDG_CONFIG_HOME="/etc/modprobed-db"' \
        --replace 'sort -k 1,1 "''$DB" -o "''$DB"' '[[ -w "''$DB" ]] && sort -k 1,1 "''$DB" -o "''$DB"'
    '';
  });
in

{
  environment = {
    etc."modprobed-db/modprobed-db.conf".text = ''
      DBPATH="/var/lib/modprobed-db"
      COLORS=dark
      IGNORE=(nct6687 v4l2loopback)
    '';
    systemPackages = [ systemModprobedDb ];
  };
  systemd = {
    services.modprobed-db = {
      description = "Store newly probed kernel modules with modprobed-db";
      path = with pkgs; [
        coreutils
        gawk
        gnugrep
        gnused
        getent
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "modprobed-db";
        Group = "modprobed-db";
        StateDirectory = "modprobed-db";
        ExecStart = "${lib.getExe systemModprobedDb} storesilent";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
      };
    };
    timers.modprobed-db = {
      description = "Periodically store newly probed kernel modules";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "1h";
      };
    };
  };
  users = {
    groups.modprobed-db = { };
    users.modprobed-db = {
      isSystemUser = true;
      group = "modprobed-db";
      home = "/var/lib/modprobed-db";
    };
  };
}
