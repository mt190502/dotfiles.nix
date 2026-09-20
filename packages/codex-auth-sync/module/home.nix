{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.codex-auth-sync;

  entrySubmodule = {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Short name for logs, backups and state files.";
      };
      live = lib.mkOption {
        type = lib.types.str;
        description = "Absolute path of the tool's live auth file (must become a real regular file).";
      };
      key = lib.mkOption {
        type = lib.types.str;
        description = "Provider key inside the JSON doc that holds the Codex OAuth triple.";
      };
      secret = lib.mkOption {
        type = lib.types.str;
        description = "Absolute path of the sops-encrypted seed/sync mirror in the dotfiles repo.";
      };
    };
  };

  configFile = pkgs.writeText "codex-auth-sync.json" (
    builtins.toJSON {
      dotfiles = cfg.dotfilesRepo;
      state_dir = cfg.stateDir;
      age_key_file = cfg.ageKeyFile;
      entries = map (e: {
        inherit (e)
          name
          live
          key
          secret
          ;
      }) cfg.entries;
    }
  );
in
{
  options.programs.codex-auth-sync = {
    enable = lib.mkEnableOption "Codex/OpenAI OAuth auto-refresh for opencode and prime-agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../default.nix {
        inherit configFile;
      };
      defaultText = lib.literalExpression "pkgs.callPackage ../default.nix { inherit configFile; }";
      description = "The codex-auth-sync package, wrapped with the generated JSON config.";
    };

    dotfilesRepo = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/dotfiles.nix";
      description = "Absolute path of the dotfiles (sops) repository used for seed/sync.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.local/state/codex-auth";
      description = "Directory for sops seeds, backups and the refresh lock.";
    };

    ageKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      description = "Age key file used by sops when the sync job re-encrypts refreshed tokens.";
    };

    entries = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule entrySubmodule);
      default = [
        {
          name = "opencode";
          live = "${config.home.homeDirectory}/.local/share/opencode/auth.json";
          key = "openai";
          secret = "${cfg.dotfilesRepo}/secrets/${config.home.username}/opencode/secret.txt";
        }
        {
          name = "prime-agent";
          live = "${config.home.homeDirectory}/.prime/agent/auth.json";
          key = "openai-codex";
          secret = "${cfg.dotfilesRepo}/secrets/${config.home.username}/prime-agent/secret.txt";
        }
      ];
      description = "Credential entries managed by codex-auth-sync.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Runs inside every home-manager activation, right after files/links are
    # written. If sops (or anything else) left a SYMLINK at a live auth.json
    # path, convert it into a real regular file (freshest of
    # live/backup/seed/sops wins) so refreshed tokens can never be clobbered.
    home.activation.codexAuthDetach = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${cfg.package}/bin/codex-auth-sync migrate || true
    '';

    systemd.user.services.codex-auth-refresh = {
      Unit = {
        Description = "Refresh Codex/OpenAI OAuth tokens and mirror them into the sops repo";
        After = [ "sops-nix.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/codex-auth-sync refresh";
        Environment = [ "SOPS_AGE_KEY_FILE=${cfg.ageKeyFile}" ];
      };
    };

    systemd.user.timers.codex-auth-refresh = {
      Unit.Description = "Periodically refresh Codex/OpenAI OAuth tokens";
      Timer = {
        OnBootSec = "10min";
        OnUnitActiveSec = "6h";
        RandomizedDelaySec = "20min";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
