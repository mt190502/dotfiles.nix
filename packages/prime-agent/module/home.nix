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

  modelsConfig = pkgs.writeText "prime-agent-model-sources.json" (
    builtins.toJSON {
      target = "${config.home.homeDirectory}/.prime/agent/models.json";
      providers = lib.mapAttrs (_: provider: {
        inherit (provider)
          name
          baseUrl
          api
          modelsUrl
          detailed
          requiredEndpoints
          visionMarkers
          defaultContextWindow
          defaultMaxTokens
          compat
          ;
        keyFile = if provider.keyFile != null then toString provider.keyFile else null;
        inherit (provider) apiKey;
      }) cfg.providers;
    }
  );
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
      description = "Legacy TypeScript extensions preserved for reference; Prime Agent v0.10 Rust does not execute them.";
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
        OpenAI-compatible providers whose public catalogs are synced into
        Prime Agent's Rust models.json during Home Manager activation.
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
        ) cfg.extensions;

      activation = {
        primeAgentModels = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          lib.optionalString (cfg.providers != { }) ''
            ${pkgs.python3}/bin/python3 ${./update-models.py} ${modelsConfig} || echo "prime-agent: model catalog update failed; keeping existing models.json" >&2
          ''
        );

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
