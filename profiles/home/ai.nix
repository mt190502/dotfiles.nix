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
  imports = [ inputs.self.homeModules.prime-agent ];

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
  ## Prime Agent
  #
  ########################################
  programs.prime-agent = {
    enable = true;
    package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.prime-agent;
    context = ''
      # NixOS Environment Disclaimer

      - Some packages is NOT available system-wide like python3 etc.
      - To use missing packages, find package name and run: `nix shell nixpkgs#<pkg> -c`
        - For example, to use python3, run: `nix shell nixpkgs#python3 -c python3 --version`
      - The same applies to other packages not installed system-wide.
    '';
    settings = {
      mcpServers = {
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
        };
        gh_grep = {
          type = "http";
          url = "https://mcp.grep.app";
        };
        exa = {
          type = "http";
          url = "https://mcp.exa.ai/mcp";
        };
      };
    };
    keybindings = {
      "tui.editor.cursorLeft" = [
        "left"
        "alt+shift+b"
      ];
      "tui.editor.cursorRight" = [
        "right"
        "alt+shift+f"
      ];
      "tui.editor.cursorWordLeft" = [
        "alt+left"
        "alt+b"
        "alt+shift+left"
      ];
      "tui.editor.cursorWordRight" = [
        "alt+right"
        "alt+f"
        "alt+shift+right"
      ];
      "tui.editor.cursorLineStart" = [
        "home"
        "alt+shift+a"
      ];
      "tui.editor.cursorLineEnd" = [
        "end"
        "alt+shift+e"
      ];
      "tui.editor.jumpForward" = "alt+shift+]";
      "tui.editor.jumpBackward" = "alt+shift+[";
      "tui.editor.deleteCharForward" = [
        "delete"
        "alt+shift+d"
      ];
      "tui.editor.deleteWordBackward" = [
        "alt+backspace"
        "alt+shift+w"
      ];
      "tui.editor.deleteToLineStart" = "alt+shift+u";
      "tui.editor.deleteToLineEnd" = "alt+shift+k";
      "tui.editor.yank" = "alt+shift+y";
      "tui.editor.undo" = "alt+shift+-";
      "tui.input.newLine" = [
        "shift+enter"
        "alt+shift+enter"
      ];
      "tui.input.tab" = [ ];
      "tui.input.copy" = "alt+shift+c";
      "tui.viewport.follow" = [
        "ctrl+shift+down"
        "alt+shift+down"
      ];
      "tui.select.cancel" = [
        "escape"
        "alt+shift+0"
      ];
      "app.clear" = [
        "ctrl+c"
        "alt+shift+q"
      ];
      "app.exit" = "alt+shift+x";
      "app.suspend" = "alt+shift+z";
      "app.model.select" = "alt+shift+l";
      "app.tools.expand" = "alt+shift+o";
      "app.messages.expand" = "alt+shift+p";
      "app.edits.expand" = "alt+shift+j";
      "app.thinking.toggle" = "alt+shift+t";
      "app.heartbeats.open" = "alt+shift+r";
      "app.editor.external" = "alt+shift+g";
      "app.prompt.stash" = "alt+shift+s";
      "app.message.moveEarlier" = "alt+shift+pageUp";
      "app.message.moveLater" = "alt+shift+pageDown";
      "app.clipboard.pasteImage" = [
        "ctrl+v"
        "alt+shift+v"
      ];
      "app.agents.new" = "alt+shift+n";
      "app.agents.delete" = "alt+shift+delete";
      "app.agents.program" = "alt+shift+1";
      "app.agents.rename" = "alt+shift+2";
      "app.tree.foldOrUp" = "alt+shift+home";
      "app.tree.unfoldOrDown" = "alt+shift+end";
      "app.models.save" = "alt+shift+3";
      "app.models.enableAll" = "alt+shift+4";
      "app.models.clearAll" = "alt+shift+5";
      "app.models.toggleProvider" = "alt+shift+6";
      "app.tree.filter.default" = "alt+shift+7";
      "app.tree.filter.noTools" = "alt+shift+8";
      "app.tree.filter.userOnly" = "alt+shift+9";
      "app.tree.filter.labeledOnly" = "alt+shift+,";
      "app.tree.filter.all" = "alt+shift+.";
      "app.tree.filter.cycleForward" = "alt+shift+/";
      "app.tree.filter.cycleBackward" = [
        "shift+ctrl+o"
        "alt+shift+\\"
      ];
    };
    extensions = {
      "permission-modes.ts" = ''
        import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent"

        type Mode = "Build" | "Write"

        const riskyCommands = [
          /\brm\s+/i,
          /\bsudo(?:\s|$)/i,
          /\bdd\s+/i,
          /\bmkfs[^\s"'`]*/i,
          /\bchmod\s+/i,
          /\bchown\s+/i,
          /\bshutdown[^\s"'`]*/i,
          /\breboot[^\s"'`]*/i,
          /\bkill[^\s"'`]*/i,
          /\bmv\s+/i,
          /\btee\s+/i,
          /\bln\s+/i,
          /\bcargo\s+/i,
          /\bpip(?:3)?\s+/i,
          /\bnpm\s+/i,
        ]

        export default function (pi: ExtensionAPI) {
          let activeMode: Mode = "Build"

          function updateStatus(ctx: ExtensionContext) {
            ctx.ui.setStatus("permission-mode", "mode:" + activeMode)
          }

          function setMode(mode: Mode, ctx: ExtensionContext) {
            activeMode = mode
            pi.appendEntry("permission-mode", { mode })
            updateStatus(ctx)
            ctx.ui.notify(mode + " mode enabled", "info")
          }

          async function requestApproval(ctx: ExtensionContext, title: string, action: string) {
            if (!ctx.hasUI) return false
            const choice = await ctx.ui.select(title + ":\n\n" + action, ["Allow", "Block"])
            return choice === "Allow"
          }

          pi.registerFlag("agent-mode", {
            description: "Permission mode: Build or Write",
            type: "string",
          })

          pi.registerCommand("mode", {
            description: "Switch between Build and Write permission modes",
            handler: async (args, ctx) => {
              const requested = args.trim().toLowerCase()
              if (requested === "build") {
                setMode("Build", ctx)
                return
              }
              if (requested === "write") {
                setMode("Write", ctx)
                return
              }

              const selected = await ctx.ui.select("Permission mode", ["Build", "Write"])
              if (selected === "Build" || selected === "Write") setMode(selected, ctx)
            },
          })

          pi.registerShortcut("tab", {
            description: "Cycle Build and Write permission modes",
            handler: async (ctx) => setMode(activeMode === "Build" ? "Write" : "Build", ctx),
          })

          pi.on("tool_call", async (event, ctx) => {
            if (event.toolName !== "bash" && event.toolName !== "ipython") return

            const input = event.input as Record<string, unknown>
            const action = String(event.toolName === "bash" ? input.command ?? "" : input.code ?? "")

            const containsBashCall = event.toolName === "bash" || /\bbash\s*\(/.test(action)
            if (!containsBashCall) return

            if (activeMode === "Build") {
              const allowed = await requestApproval(ctx, "Build mode approval", action)
              if (!allowed) return { block: true, reason: "Blocked by Build mode" }
              return
            }

            const isRisky = riskyCommands.some((pattern) => pattern.test(action))
            if (!isRisky) return

            const allowed = await requestApproval(ctx, "Write mode risky command", action)
            if (!allowed) return { block: true, reason: "Risky command blocked by Write mode" }
          })

          pi.on("before_agent_start", async (event) => ({
            systemPrompt:
              event.systemPrompt +
              (activeMode === "Build"
                ? "\n\nPermission mode: Build. Ask for approval before execution."
                : "\n\nPermission mode: Write. Proceed without approval except for configured risky shell commands."),
          }))

          pi.on("session_start", async (_event, ctx) => {
            const entries = ctx.sessionManager.getEntries()
            const saved = entries
              .filter((entry: { type: string; customType?: string }) =>
                entry.type === "custom" && entry.customType === "permission-mode"
              )
              .pop() as { data?: { mode?: Mode } } | undefined

            const flag = pi.getFlag("agent-mode")
            if (typeof flag === "string" && flag.toLowerCase() === "write") activeMode = "Write"
            else if (typeof flag === "string" && flag.toLowerCase() === "build") activeMode = "Build"
            else if (saved?.data?.mode === "Build" || saved?.data?.mode === "Write") activeMode = saved.data.mode

            updateStatus(ctx)
          })
        }
      '';
      "terminal-bell.ts" = ''
        import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"

        export default function (pi: ExtensionAPI) {
          pi.on("agent_end", async () => {
            process.stdout.write("\x07")
          })
        }
      '';
      "commandcode.ts" = ''
        import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"

        interface CommandCodeModel {
          id: string
          context_length?: number
        }

        export default async function (pi: ExtensionAPI) {
          try {
            const res = await fetch("http://127.0.0.1:8082/v1/models", {
              signal: AbortSignal.timeout(2000),
            })
            if (!res.ok) return

            const data = (await res.json()) as { data?: CommandCodeModel[] }
            const models = (data.data ?? []).map((model) => ({
              id: model.id,
              name: model.id.split("/").pop() ?? model.id,
              reasoning: false,
              input: ["text"] as ("text" | "image")[],
              cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
              contextWindow: model.context_length ?? 1000000,
              maxTokens: 16384,
            }))
            if (models.length === 0) return

            pi.registerProvider("commandcode", {
              name: "CommandCode",
              baseUrl: "http://127.0.0.1:8082/v1",
              apiKey: "!cat ${config.sops.secrets."commandcode".path}",
              api: "openai-completions",
              models,
            })
          } catch {
            // proxy not running yet
          }
        }
      '';
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
    package = pkgs-unstable.opencode.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
                substituteInPlace packages/core/src/filesystem/search.ts \
                  --replace-fail 'import { FileSystem } from "../filesystem"' \
                    'import type { FileSystem } from "../filesystem"
        import { Entry, Match } from "@opencode-ai/schema/filesystem"' \
                  --replace-fail "FileSystem.Entry.make" "Entry.make" \
                  --replace-fail "FileSystem.Match.make" "Match.make"
      '';
    });
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
  home = {
    sessionVariables.OPENCODE_CONFIG_DIR = "${config.home.homeDirectory}/.config/opencode/config.d";
    file = {
      ".config/opencode/config.d/.keep".text = "";
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
  };
}
