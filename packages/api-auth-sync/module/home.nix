{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.api-auth-sync;

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
        description = "Provider key inside the JSON doc that holds the API OAuth triple.";
      };
      provider = lib.mkOption {
        type = lib.types.enum [
          "openai"
          "anthropic"
        ];
        default = "openai";
        description = "OAuth token endpoint to use for refresh.";
      };
      optional = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Skip refresh when the user has not logged in to this provider yet.";
      };
    };
  };

  configFile = pkgs.writeText "api-auth-sync.json" (
    builtins.toJSON {
      state_dir = cfg.stateDir;
      entries = map (e: {
        inherit (e)
          name
          live
          key
          provider
          optional
          ;
      }) cfg.entries;
    }
  );
in
{
  options.programs.api-auth-sync = {
    enable = lib.mkEnableOption "API OAuth auto-refresh for opencode and prime-agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../default.nix {
        inherit configFile;
      };
      defaultText = lib.literalExpression "pkgs.callPackage ../default.nix { inherit configFile; }";
      description = "The api-auth-sync package, wrapped with the generated JSON config.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.local/state/codex-auth";
      description = "Directory for sops-nix-deployed seeds, backups and the refresh lock (the sops-nix homeTarget path stays here so deployed seeds remain discoverable).";
    };

    entries = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule entrySubmodule);
      default = [
        {
          name = "opencode";
          live = "${config.home.homeDirectory}/.local/share/opencode/auth.json";
          key = "openai";
        }
        {
          name = "prime-agent";
          live = "${config.home.homeDirectory}/.prime/agent/auth.json";
          key = "openai-codex";
        }
        {
          name = "prime-agent-anthropic";
          live = "${config.home.homeDirectory}/.prime/agent/auth.json";
          key = "anthropic";
          provider = "anthropic";
          optional = true;
        }
      ];
      description = "Provider credential entries managed by api-auth-sync.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ cfg.package ];

        # Runs inside every home-manager activation, right after files/links are
        # written. If sops (or anything else) left a SYMLINK at a live auth.json
        # path, convert it into a real regular file (freshest of
        # live/backup/seed/sops wins) so refreshed tokens can never be clobbered.
        home.activation.apiAuthDetach = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${cfg.package}/bin/api-auth-sync migrate || echo "api-auth-sync: migration needs attention; inspect credentials before using AI tools" >&2
        '';
      }

      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        launchd.agents.api-auth-refresh = {
          enable = true;
          config = {
            ProgramArguments = [
              "${cfg.package}/bin/api-auth-sync"
              "refresh"
            ];
            RunAtLoad = true;
            StartInterval = 6 * 60 * 60;
            ProcessType = "Background";
            StandardOutPath = "${cfg.stateDir}/launchd.out.log";
            StandardErrorPath = "${cfg.stateDir}/launchd.err.log";
          };
        };
      })

      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        systemd.user.services.api-auth-refresh = {
          Unit = {
            Description = "Refresh API OAuth tokens";
            After = [ "sops-nix.service" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${cfg.package}/bin/api-auth-sync refresh";
          };
        };

        systemd.user.timers.api-auth-refresh = {
          Unit.Description = "Periodically refresh API OAuth tokens";
          Timer = {
            OnBootSec = "10min";
            OnUnitActiveSec = "6h";
            RandomizedDelaySec = "20min";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      })
    ]
  );
}
