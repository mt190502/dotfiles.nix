{ config, pkgs-unstable, ... }:

let
  fontcfg =
    config.stylix.fonts or {
      monospace.name = "MesloLGS NF";
      sizes = {
        applications = 10;
        terminal = 9;
      };
    };
in
{
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;
    userSettings = {
      agent = {
        default_model = {
          provider = "copilot";
          model = "gpt-5.3-codex";
        };
        model_parameters = [ ];
      };
      autosave = {
        after_delay = {
          milliseconds = 1000;
        };
      };
      buffer_font_fallbacks = [
        "Fira Code"
        "Droid Sans"
        "Droid Sans Fallback"
      ];
      buffer_font_family = "Iosevka Nerd Font";
      buffer_font_size = fontcfg.sizes.applications + 4.5;
      buffer_font_weight = 500;
      buffer_line_height = {
        custom = 1.25;
      };
      diagnostics = {
        inline = {
          enabled = true;
          padding = 4;
          min_column = 0;
          max_severity = null;
        };
        include_warnings = true;
      };
      features = {
        edit_prediction_provider = "copilot";
      };
      gutter = {
        line_numbers = true;
      };
      icon_theme = "Material Icon Theme";
      inlay_hints = {
        show_value_hints = true;
        show_type_hints = false;
        show_parameter_hints = true;
        show_other_hints = true;
        show_background = false;
        enabled = true;
      };
      languages = {
        TypeScript = {
          enable_language_server = true;
          format_on_save = "on";
          code_actions_on_format = {
            "source.addMissingImports.ts" = true;
            "source.fixAll.ts" = true;
            "source.organizeImports" = true;
            "source.removeUnused.ts" = true;
            "source.sortImports" = true;
          };
          language_servers = [
            "vtsls"
          ];
          remove_trailing_whitespace_on_save = true;
          prettier = {
            allowed = true;
          };
        };
        Nix = {
          show_edit_predictions = true;
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
      };
      lsp = {
        nixd = {
          settings = {
            diagnostics = {
              ignored = [
                "unused_binding"
                "unused_with"
              ];
            };
            formatting = {
              command = [
                "nixfmt"
              ];
            };
          };
        };
      };
      lsp_document_colors = "inlay";
      minimap = {
        show = "never";
      };
      prettier = {
        allowed = false;
      };
      relative_line_numbers = "enabled";
      show_edit_predictions = true;
      terminal = {
        font_family = fontcfg.monospace.name;
        font_fallbacks = [
          "Fira Code"
          "Droid Sans"
          "Droid Sans Fallback"
        ];
        font_size = fontcfg.sizes.terminal + 3.5;
      };
      theme = "Ayu Dark";
      ui_font_family = fontcfg.monospace.name;
      ui_font_size = fontcfg.sizes.terminal + 4.5;
      vim_mode = true;
    };
    userKeymaps = [
      {
        context = "((os != macos && Editor) && edit_prediction_conflict)";
        bindings = {
          alt-l = null;
        };
      }
      {
        context = "((vim_mode == normal || vim_mode == visual) || vim_mode == operator)";
        bindings = {
          "[ e" = null;
        };
      }
      {
        context = "((vim_mode == normal || vim_mode == visual) || vim_mode == operator)";
        bindings = {
          "] e" = null;
        };
      }
      {
        context = "((vim_mode == normal || vim_mode == visual) || vim_mode == operator)";
        bindings = {
          ctrl-j = "editor::MoveLineDown";
        };
      }
      {
        context = "((vim_mode == normal || vim_mode == visual) || vim_mode == operator)";
        bindings = {
          ctrl-k = "editor::MoveLineUp";
        };
      }
      {
        context = "(Editor && edit_prediction)";
        bindings = {
          alt-l = null;
        };
      }
      {
        context = "(Editor && edit_prediction)";
        bindings = {
          ctrl-right = "editor::AcceptPartialEditPrediction";
        };
      }
      {
        context = "(Editor && edit_prediction)";
        bindings = {
          tab = "editor::AcceptEditPrediction";
        };
      }
      {
        context = "(Editor && edit_prediction_conflict)";
        bindings = {
          alt-l = null;
        };
      }
      {
        context = "(Editor && edit_prediction_conflict)";
        bindings = {
          tab = "editor::AcceptEditPrediction";
        };
      }
      {
        context = "(ProjectPanel && not_editing)";
        bindings = {
          ctrl-d = null;
        };
      }
      {
        context = "(VimControl && !menu)";
        bindings = {
          ctrl-d = null;
        };
      }
      {
        context = "Editor";
        bindings = {
          alt-shift-down = null;
        };
      }
      {
        context = "Editor";
        bindings = {
          alt-shift-up = null;
        };
      }
      {
        context = "Editor";
        bindings = {
          ctrl-shift-down = [
            "editor::AddSelectionBelow"
            { skip_soft_wrap = true; }
          ];
        };
      }
      {
        context = "Editor";
        bindings = {
          ctrl-shift-up = [
            "editor::AddSelectionAbove"
            { skip_soft_wrap = true; }
          ];
        };
      }
      {
        context = "showing_completions";
        bindings = {
          "ctrl-d" = null;
        };
      }
      {
        context = "vim_mode == insert";
        bindings = {
          "ctrl-d" = null;
          "ctrl-s" = null;
        };
      }
      {
        context = "vim_mode == literal";
        bindings = {
          "ctrl-d" = null;
          "ctrl-s" = null;
        };
      }
      {
        context = "vim_mode";
        bindings = {
          ctrl-d = [
            "editor::SelectNext"
            { replace_newest = false; }
          ];
        };
      }
    ];
  };
}
