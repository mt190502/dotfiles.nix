## ------------------------------------------------------------------------------------ ##
#  AI Tools Bundle                                                                       #
## ------------------------------------------------------------------------------------ ##
{
  config,
  inputs,
  lib,
  osConfig ? null,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  commandcode-proxy-bin = "${
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.commandcode-proxy
  }/bin/commandcode-proxy";
in

{
  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages = [ inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.prime-agent ];

  ########################################
  #
  ## CommandCode Proxy Server
  #
  ########################################
  systemd.user.services.commandcode-proxy = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "CommandCode Proxy Server";
      After = [ "network.target" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = commandcode-proxy-bin;
      Restart = "always";
      RestartSec = 5;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  launchd.agents.commandcode-proxy =
    lib.mkIf (osConfig != null && pkgs.stdenv.hostPlatform.isDarwin)
      {
        enable = true;
        config = {
          ProgramArguments = [ commandcode-proxy-bin ];
          RunAtLoad = true;
          KeepAlive = true;
          WorkingDirectory = config.home.homeDirectory;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/commandcode-proxy.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/commandcode-proxy.log";
        };
      };

  ########################################
  #
  ## OpenCode
  #
  ########################################
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs-unstable.opencode;
    context = ''
      # NixOS Environment Disclaimer

      - Some packages is NOT available system-wide like python3 etc.
      - To use missing packages, find package name and run: `nix shell nixpkgs#<pkg> -c`
        - For example, to use python3, run: `nix shell nixpkgs#python3 -c python3 --version`
      - The same applies to other packages not installed system-wide.
    '';
    settings = {
      # theme = "flexoki";
      plugin = [
        "opencode-antigravity-auth@latest"
        "@slkiser/opencode-quota"
      ];
      mcp = {
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
        };
        gh_grep = {
          type = "remote";
          url = "https://mcp.grep.app";
        };
        exa = {
          type = "remote";
          url = "https://mcp.exa.ai/mcp";
        };
      };
      agent = {
        "build" = {
          mode = "primary";
          permission = {
            bash = "ask";
          };
        };
        "Write" = {
          permission = {
            bash = {
              "*" = "allow";
              "rm *" = "ask";
              "sudo *" = "ask";
              "dd *" = "ask";
              "mkfs*" = "ask";
              "chmod *" = "ask";
              "chown *" = "ask";
              "shutdown*" = "ask";
              "reboot*" = "ask";
              "kill*" = "ask";
              "mv *" = "ask";
              "tee *" = "ask";
              "ln *" = "ask";
              "cargo *" = "ask";
              "pip *" = "ask";
              "npm *" = "ask";
            };
          };
        };
      };
      provider = {
        commandcode = {
          name = "CommandCode";
          options = {
            baseURL = "http://127.0.0.1:8082/v1";
            apiKey = "{file:${config.sops.secrets."commandcode".path}}";
          };
        };
      };
    };
  };
  home.file = {
    ".config/opencode/plugin/terminal-bell.ts".text = ''
      import type { Plugin } from "@opencode-ai/plugin"
      export const TerminalBell: Plugin = async ({ project, client, $, directory, worktree }) => {
        return {
          event: async ({ event }) => {
            if (event.type === "session.idle") {
              await Bun.write(Bun.stdout, "\x07")
            }
          }
        }
      }
    '';
    ".config/opencode/plugin/commandcode.ts".text = ''
      import type { Plugin } from "@opencode-ai/plugin"

      export default (async () => {
        let models: Record<string, any> = {}

        try {
          const res = await fetch("http://127.0.0.1:8082/v1/models")
          if (res.ok) {
            const data = await res.json()
            for (const model of data.data ?? []) {
              models[model.id] = {
                name: model.id.split("/").pop() ?? model.id,
                limit: { context: 1000000, output: 16384 },
                modalities: { input: ["text"], output: ["text"] },
              }
            }
          }
        } catch {
          // proxy not running yet
        }

        return {
          config: (cfg) => {
            cfg.provider ??= {}
            cfg.provider.commandcode ??= { models: {} }
            cfg.provider.commandcode.models = {
              ...models,
              ...(cfg.provider.commandcode.models ?? {}),
            }
          },
        }
      }) satisfies Plugin
    '';
  };
}
