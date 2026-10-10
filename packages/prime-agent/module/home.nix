{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.prime-agent;
  jsonFormat = pkgs.formats.json { };
  settingsJson = builtins.toJSON cfg.settings;
  keybindingsJson = builtins.toJSON cfg.keybindings;
  substitutionScript = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (p: f: ''
      ${pkgs.jq}/bin/jq --arg value "$(cat ${f})" 'walk(if type == "string" then (split("${p}") | join($value)) else . end)' "$temporary" > "$temporary.substituted"
      mv -f "$temporary.substituted" "$temporary"
    '') cfg.substitutions
  );

  registerProviderCall =
    name: provider:
    let
      keyExpr =
        if provider.keyFile != null then
          ''fs.readFileSync("${provider.keyFile}", "utf8").trim()''
        else if provider.apiKey != null then
          builtins.toJSON provider.apiKey
        else
          "undefined";
      modelsUrl =
        if provider.modelsUrl != null then
          provider.modelsUrl
        else
          "${provider.baseUrl}/models" + (if provider.detailed then "?detailed=true" else "");
      filterExpr =
        if provider.requiredEndpoints != [ ] then
          "(model.supported_endpoints ?? []).some((endpoint) => ${builtins.toJSON provider.requiredEndpoints}.includes(endpoint))"
        else
          "model.capabilities?.tool_calling !== false";
      compatJson = {
        supportsDeveloperRole = false;
        maxTokensField = "max_tokens";
      }
      // provider.compat;
      modelExpr =
        if provider.detailed then
          ''
            {
              id: model.id,
              name: model.name ?? model.id,
              reasoning: model.capabilities?.reasoning === true,
              thinkingLevelMap: thinkingLevelMap(model.reasoning_efforts),
              input: model.architecture?.input_modalities?.includes("image")
                ? ["text", "image"]
                : ["text"],
              cost: {
                input: model.pricing?.prompt ?? 0,
                output: model.pricing?.completion ?? 0,
                cacheRead: (model.pricing?.cacheReadInputPer1kTokens ?? 0) * 1000,
                cacheWrite: 0,
              },
              contextWindow: model.context_length ?? ${toString provider.defaultContextWindow},
              maxTokens: model.max_output_tokens ?? ${toString provider.defaultMaxTokens},
              compat: ${builtins.toJSON compatJson},
            }
          ''
        else
          ''
            {
              id: model.id,
              name: model.id.split("/").pop() ?? model.id,
              reasoning:
                model.id.toLowerCase().includes("r1")
                || model.id.toLowerCase().includes("reasoning"),
              input: inputModalities(model.id, ${builtins.toJSON provider.visionMarkers}),
              cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
              contextWindow: model.context_length ?? ${toString provider.defaultContextWindow},
              maxTokens: ${toString provider.defaultMaxTokens},
              compat: ${builtins.toJSON compatJson},
            }
          '';
    in
    ''
      try {
        const apiKey = ${keyExpr}
        if (apiKey) {
          const models = (await fetchModels(${builtins.toJSON modelsUrl}))
            .filter((model) => ${filterExpr})
            .map((model) => (${modelExpr}))
          if (models.length > 0) {
            pi.registerProvider(${builtins.toJSON name}, {
              name: ${builtins.toJSON provider.name},
              baseUrl: ${builtins.toJSON provider.baseUrl},
              apiKey,
              api: ${builtins.toJSON provider.api},
              models,
            })
          }
        }
      } catch {
        // provider catalog not reachable yet
      }
    '';

  providerExtension = lib.optionalString (cfg.providers != { }) ''
    import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"
    import * as fs from "fs"

    interface CatalogModel {
      id: string
      name?: string
      context_length?: number
      max_output_tokens?: number | null
      architecture?: {
        input_modalities?: string[]
      }
      capabilities?: {
        reasoning?: boolean
        tool_calling?: boolean
      }
      reasoning_efforts?: string[]
      supported_endpoints?: string[]
      pricing?: {
        prompt?: number
        completion?: number
        cacheReadInputPer1kTokens?: number
      }
    }

    function thinkingLevelMap(efforts?: string[]) {
      if (!efforts?.length) return undefined
      const supports = (level: string) => efforts.includes(level)
      return {
        off: supports("none") ? "none" : null,
        minimal: supports("minimal") ? "minimal" : supports("low") ? "low" : null,
        low: supports("low") ? "low" : supports("medium") ? "medium" : null,
        medium: supports("medium") ? "medium" : supports("high") ? "high" : null,
        high: supports("high") ? "high" : supports("xhigh") ? "xhigh" : null,
        xhigh: supports("xhigh") ? "xhigh" : supports("max") ? "max" : null,
        max: supports("max") ? "max" : supports("xhigh") ? "xhigh" : null,
      }
    }

    function inputModalities(id: string, markers: string[]): ("text" | "image")[] {
      const lower = id.toLowerCase()
      const vision =
        markers.some((marker) => lower.includes(marker)) ||
        (lower.includes("gpt-5") && !lower.includes("codex"))
      return vision ? ["text", "image"] : ["text"]
    }

    async function fetchModels(url: string): Promise<CatalogModel[]> {
      const res = await fetch(url, { signal: AbortSignal.timeout(10000) })
      if (!res.ok) return []
      const data = (await res.json()) as { data?: CatalogModel[] }
      return data.data ?? []
    }

    export default async function (pi: ExtensionAPI) {
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList registerProviderCall cfg.providers)}
    }
  '';
in
{
  options.programs.prime-agent = {
    enable = lib.mkEnableOption "Prime Agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../default.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ../default.nix { }";
      description = "The Prime Agent package to install.";
    };

    context = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Global instructions written to ~/.prime/agent/AGENTS.md.";
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = "Prime Agent settings written to ~/.prime/agent/settings.json.";
    };

    substitutions = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = ''
        Placeholder strings in settings, replaced with the trimmed contents of the
        given files during activation (e.g. sops-nix secrets). Placeholders must
        not contain quotes or backslashes.
      '';
    };

    keybindings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = "Prime Agent keybindings written to ~/.prime/agent/keybindings.json.";
    };

    extensions = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = { };
      description = "Prime Agent extension files, keyed by paths relative to ~/.prime/agent/extensions/.";
    };

    providers = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }: {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Display name shown for the provider in the UI.";
              };
              baseUrl = lib.mkOption {
                type = lib.types.str;
                description = "API endpoint URL.";
              };
              api = lib.mkOption {
                type = lib.types.str;
                default = "openai-completions";
                description = "Streaming API type used for the provider.";
              };
              keyFile = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = "File the API key is read from at extension load (e.g. a sops secret path).";
              };
              apiKey = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "API key as an environment variable name or literal value.";
              };
              modelsUrl = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Full model catalog URL. Defaults to `<baseUrl>/models`.";
              };
              detailed = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                  Append ?detailed=true and map catalog metadata (capabilities, pricing,
                  context window) onto each model.
                '';
              };
              requiredEndpoints = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Only keep models advertising one of these supported endpoints.";
              };
              visionMarkers = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                  "z-ai/"
                  "vision"
                  "gemini"
                  "kimi"
                  "minimax"
                  "mimo"
                  "inkling"
                  "stepfun"
                ];
                description = "Model id markers that switch basic-mode input modalities to text+image.";
              };
              defaultContextWindow = lib.mkOption {
                type = lib.types.int;
                default = 128000;
                description = "Context window used when the catalog does not report one.";
              };
              defaultMaxTokens = lib.mkOption {
                type = lib.types.int;
                default = 16384;
                description = "Max output tokens used when the catalog does not report one.";
              };
              compat = lib.mkOption {
                type = lib.types.attrsOf jsonFormat.type;
                default = { };
                description = "OpenAI compatibility overrides merged onto every model.";
              };
            };
          }
        )
      );
      default = { };
      description = ''
        OpenAI-compatible providers registered through a generated dynamic-providers
        extension. Each entry fetches its model catalog at agent startup and calls
        registerProvider with the discovered models.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      file =
        lib.optionalAttrs (cfg.context != "") {
          ".prime/agent/AGENTS.md".text = cfg.context;
        }
        // lib.mapAttrs' (
          name: text:
          lib.nameValuePair ".prime/agent/extensions/${name}" {
            inherit text;
          }
        ) cfg.extensions
        // lib.optionalAttrs (cfg.providers != { }) {
          ".prime/agent/extensions/dynamic-providers.ts".text = providerExtension;
        };

      activation = {
        primeAgentSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          target="${config.home.homeDirectory}/.prime/agent/settings.json"
          temporary="$target.home-manager-tmp"
          mkdir -p "$(dirname "$target")"
          rm -f "$temporary"
          cat >"$temporary" <<'EOF'
          ${settingsJson}
          EOF
          ${substitutionScript}
          mv -f "$temporary" "$target"
        '';

        primeAgentKeybindings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          target="${config.home.homeDirectory}/.prime/agent/keybindings.json"
          temporary="$target.home-manager-tmp"
          mkdir -p "$(dirname "$target")"
          rm -f "$temporary"
          cat >"$temporary" <<'EOF'
          ${keybindingsJson}
          EOF
          mv -f "$temporary" "$target"
        '';
      };
    };
  };
}
