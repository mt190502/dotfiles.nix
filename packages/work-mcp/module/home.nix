{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  cfg = config.programs.work-mcp;
  serverArgs = lib.optionals (!cfg.customerDiscovery) [ "--no-customer-discovery" ];
  execStart = lib.concatStringsSep " " ([ "${cfg.package}/bin/work-mcp" ] ++ serverArgs);

  envVars = lib.filterAttrs (_name: value: value != "" && value != null) {
    WORK_MCP_ROOT = cfg.workRoot;
    WORK_MCP_PORT = toString cfg.port;
    WORK_MCP_BIND_HOST = cfg.listenHost;
    WORK_MCP_TOKEN = cfg.token;
    WORK_MCP_ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHosts;
    WORK_MCP_EXCLUDE = lib.concatStringsSep "," cfg.excludeCustomers;
    WORK_MCP_INSTRUCTIONS = cfg.instructions;
  };

  serverEnv = envVars // cfg.environment;

  systemdEnvironment = lib.mapAttrsToList (name: value: "${name}=${value}") serverEnv;
  launchdEnvironment = serverEnv;

  stateDir = "${config.home.homeDirectory}/.local/state/work-mcp";
in
{
  options.programs.work-mcp = {
    enable = lib.mkEnableOption "work-mcp, the local per-customer Markdown space MCP server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../default.nix { inherit pkgs-unstable; };
      defaultText = lib.literalExpression "pkgs.callPackage ../default.nix { inherit pkgs-unstable; }";
      description = "The work-mcp server package.";
    };

    workRoot = lib.mkOption {
      type = lib.types.str;
      example = lib.literalExpression "\${config.home.homeDirectory}/Projects/work";
      description = ''
        Center folder of the server; there is no default, every host must
        define it explicitly. Per-customer mode holds one directory per
        customer here (each with its own .mcp space, ensured at server
        startup); single-space mode hosts the shared .mcp space directly.
      '';
    };

    customerDiscovery = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Customer discovery mode, passed to the server as a command-line flag
        (not an environment variable). Enabled (default): one space per
        customer at <workRoot>/<customer>/.mcp/ and agents must resolve the
        customer from their working directory
        (~/Projects/work/customer1/ -> customer1) or ask the user. Disabled:
        the service runs with --no-customer-discovery and serves a single
        shared space at <workRoot>/.mcp/; no customer name is ever needed or
        asked for.
      '';
    };

    excludeCustomers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "archive"
        "internal-docs"
      ];
      description = ''
        Folder names directly under workRoot that are NOT customers, matched
        exactly and case-sensitively. Excluded folders get no .mcp space at
        server startup, appear in list_customers flagged excluded=true, and
        every page tool rejects them as customer.
      '';
    };

    listenHost = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address the Streamable HTTP transport binds to. Loopback keeps the write API private.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8776;
      description = "TCP port for the Streamable HTTP MCP endpoint (/mcp). 8765 is reserved for the remote roberto sidecar.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      description = "Streamable HTTP endpoint URL that MCP clients connect to. Computed from listenHost/port; override when binding beyond loopback.";
    };

    token = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Optional Bearer token; enforced for non-loopback Hosts when listenHost is not loopback.";
    };

    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "mcp.home.arpa" ];
      description = "Additional Host names accepted by DNS-rebinding protection when binding beyond loopback.";
    };

    instructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Optional override for the agent instructions sent on MCP initialize. Empty keeps the built-in roberto-style workflow.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables for the server process.";
    };
  };

  config = lib.mkMerge [
    {
      # Defined outside the enable gate so MCP client configs can always read it.
      programs.work-mcp.url = lib.mkDefault "http://${
        if cfg.listenHost == "0.0.0.0" || cfg.listenHost == "::" then "127.0.0.1" else cfg.listenHost
      }:${toString cfg.port}/mcp";
    }

    (lib.mkIf cfg.enable (
      lib.mkMerge [
        {
          home.packages = [ cfg.package ];

          home.activation.workMcpWorkRoot = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p "${cfg.workRoot}"
          '';
        }

        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          launchd.agents.work-mcp = {
            enable = true;
            config = {
              ProgramArguments = [ "${cfg.package}/bin/work-mcp" ] ++ serverArgs;
              RunAtLoad = true;
              KeepAlive.SuccessfulExit = false;
              ProcessType = "Background";
              EnvironmentVariables = launchdEnvironment;
              StandardOutPath = "${stateDir}/launchd.out.log";
              StandardErrorPath = "${stateDir}/launchd.err.log";
            };
          };
        })

        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          systemd.user.services.work-mcp = {
            Unit = {
              Description = "work-mcp: per-customer Markdown knowledge spaces over MCP";
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = execStart;
              Environment = systemdEnvironment;
              Restart = "on-failure";
              RestartSec = "2s";
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          };
        })
      ]
    ))
  ];
}
