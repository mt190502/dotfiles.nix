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
        primeAgentSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          target="${config.home.homeDirectory}/.prime/agent/settings.json"
          temporary="$target.home-manager-tmp"
          mkdir -p "$(dirname "$target")"
          rm -f "$temporary"
          cat >"$temporary" <<'EOF'
          ${settingsJson}
          EOF
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
