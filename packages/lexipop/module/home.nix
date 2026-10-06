{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.lexipop;

  languageType = lib.types.submodule {
    options = {
      words = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Deck used for single words in this language.";
      };
      sentences = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Deck used for sentences in this language.";
      };
    };
  };

  # JSON document read by lexipop.config.load (see the interface contract).
  configJson = pkgs.writeText "lexipop.json" (
    builtins.toJSON {
      inherit (cfg)
        ankiConnectUrl
        noteModel
        frontField
        backField
        tags
        palette
        translationTarget
        translationTargets
        excludeApps
        fallbackDeck
        wordTokenLimit
        pointerClicks
        languageNames
        ;
      languages = lib.mapAttrs (_: entry: {
        inherit (entry) words sentences;
      }) cfg.languages;
      popup = {
        inherit (cfg.popup)
          enabled
          onEverySelection
          hideWhenFocusChanges
          hideWhenSelectionCleared
          closeOnOutsideClick
          hideAfterSeconds
          settleMs
          pollSelectionMs
          labels
          ;
      };
      ai = {
        inherit (cfg.ai) enable endpoint model;
        apiKeyFile = if cfg.ai.apiKeyFile == null then null else toString cfg.ai.apiKeyFile;
      };
      ocr = {
        inherit (cfg.ocr) languages psm joinLines;
      };
    }
  );

  configPath = "${config.xdg.configHome}/lexipop/config.json";
in
{
  options.programs.lexipop = {
    enable = lib.mkEnableOption "lexipop, a selection-to-Anki capture popup";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../default.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ../default.nix { }";
      description = "The lexipop package to install.";
    };

    pointerClicks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Dismiss the popup on any real left-click anywhere. Requires the
        matching NixOS module (programs.lexipop.pointerAccess), which the host
        enables automatically when this option is true.
      '';
    };

    ankiConnectUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:8765";
      description = "AnkiConnect endpoint used to add notes.";
    };

    noteModel = lib.mkOption {
      type = lib.types.str;
      default = "Basic";
      description = "Note type (model) name used for new notes.";
    };

    frontField = lib.mkOption {
      type = lib.types.str;
      default = "Front";
      description = "Name of the note field holding the captured text.";
    };

    backField = lib.mkOption {
      type = lib.types.str;
      default = "Back";
      description = "Name of the note field holding the translation.";
    };

    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "lexipop" ];
      description = "Tags added to every created note.";
    };

    palette = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "rgb(170, 0, 0)"
        "rgb(0, 110, 170)"
        "rgb(0, 130, 0)"
        "rgb(170, 90, 0)"
        "rgb(130, 0, 170)"
        "rgb(0, 130, 130)"
        "rgb(150, 100, 0)"
      ];
      description = ''
        Colour cycle used to colour aligned (source, target) pairs: the pair
        index selects the colour. Accepts CSS colour strings; the default keeps
        the rgb(r, g, b) form used by the existing Anki cards.
      '';
    };

    translationTarget = lib.mkOption {
      type = lib.types.str;
      default = "tr";
      description = "Target language code for translations.";
    };

    translationTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = lib.literalExpression ''[ "tr" "en" "de" ]'';
      description = ''
        Extra selectable target languages for the popup, on top of
        translationTarget. The popup shows a target-language dropdown when the
        effective list (translationTargets plus translationTarget, deduplicated)
        holds more than one entry; with a single entry it keeps the static
        target-language label.
      '';
    };

    excludeApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = lib.literalExpression ''[ "dev.zed.Zed" "foot" ]'';
      description = ''
        Wayland app_ids (or X11 classes) whose selections are ignored
        completely: the popup is not shown and the text is not translated.
        The focused application is matched case-insensitively.
      '';
    };

    languages = lib.mkOption {
      type = lib.types.attrsOf languageType;
      default = { };
      example = lib.literalExpression ''
        {
          en = {
            words = "English::00: Collection::Words";
            sentences = "English::00: Collection::Sentence Mining";
          };
        }
      '';
      description = "Per-language deck mapping, keyed by ISO language code.";
    };

    fallbackDeck = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Deck used when the detected language has no mapping.";
    };

    wordTokenLimit = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1;
      description = "Maximum number of tokens for a text to count as a single word.";
    };

    popup = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show the capture popup at all.";
      };
      onEverySelection = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show the popup for every selection, not only for words.";
      };
      hideWhenFocusChanges = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Hide the popup when focus moves to a non-lexipop window.";
      };
      hideWhenSelectionCleared = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Hide the popup when the primary selection becomes empty.";
      };
      closeOnOutsideClick = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Close the popup when a click lands outside it.

          The dismiss is observed with an invisible fullscreen layer-shell
          surface per monitor (the "click catcher"), so no device group, udev
          rule or re-login is needed -- unlike pointerClicks. The surface that
          observes the click also consumes it, so that one click does not reach
          the application below. Set this to false to disable it, or leave
          pointerClicks to handle dismissals without consuming the click.
        '';
      };
      hideAfterSeconds = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 0;
        description = "Hide the popup after this many seconds without interaction (0 = never).";
      };

      pollSelectionMs = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 300;
        description = ''
          While the popup is visible, poll the primary selection every this many
          milliseconds so a dropped selection closes it even when the watch
          stream stays silent (0 disables the poller).
        '';
      };
      settleMs = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 250;
        description = "Milliseconds a selection must stay unchanged before the popup appears (0 disables the debounce).";
      };
      labels = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          detected = "(detected)";
          translation = "Translation";
          close = "Close";
          ai = "AI Translate";
          saveAs = "Save as";
          edit = "Edit…";
          word = "Word";
          sentence = "Sentence";
          targetLanguage = "Target language";
          front = "Front";
          back = "Back (translation)";
          deck = "Deck";
          colours = "Colours";
          preview = "Preview";
          reset = "Reset";
          coloursHint = "Colours appear after an AI translation.";
        };
        description = "Literal UI strings shown in the popup and the editor.";
      };
    };

    languageNames = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''
        {
          en = "İngilizce";
          de = "Almanca";
          tr = "Türkçe";
        }
      '';
      description = "Display names for language codes; missing codes fall back to the trans English name or the upper-cased code.";
    };

    ai = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the optional AI translation button.";
      };
      endpoint = lib.mkOption {
        type = lib.types.str;
        default = "https://api.nano-gpt.com/api/v1";
        description = "OpenAI-compatible API endpoint used by the AI button.";
      };
      model = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Model name used for AI translation.";
      };
      apiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "File the API key is read from at request time (e.g. a sops secret path).";
      };
    };

    ocr = {
      languages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "eng" ];
        example = lib.literalExpression ''[ "eng" "deu" ]'';
        description = ''
          Tesseract language codes used for OCR capture (the `ocr` subcommand
          and the mod+shift+d sway binding). Multiple codes are passed to
          tesseract with -l in this order and are combined by tesseract.
        '';
      };
      psm = lib.mkOption {
        type = lib.types.ints.positive;
        default = 6;
        description = ''
          Tesseract page segmentation mode (--psm) for OCR capture. The default
          6 treats the image as one uniform block of text.
        '';
      };
      joinLines = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Join OCR lines that were wrapped by the layout into one line, while
          keeping blank-line paragraph breaks. Disable to keep line breaks as
          recognised by tesseract.
        '';
      };
    };

    systemd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Start the lexipop daemon as a systemd user service (Linux only).";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ cfg.package ];
        home.file.".config/lexipop/config.json".source = configJson;
      }

      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.systemd.enable) {
        systemd.user.services.lexipop = {
          Unit = {
            Description = "lexipop selection-to-Anki capture popup";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${cfg.package}/bin/lexipop daemon";
            Restart = "on-failure";
            Environment = [ "LEXIPOP_CONFIG=${configPath}" ];
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      })
    ]
  );
}
