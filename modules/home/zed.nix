{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;
    extensions = [
      "basher"
      "dockerfile"
      "html"
      "markdownlint"
      "material-icon-theme"
      "nix"
      "rainbow-csv"
      "terraform"
    ];
    extraPackages = with pkgs; [
      nixd
      vtsls
    ];
    userSettings = {
      agent = {
        default_model = {
          effort = "max";
          enable_thinking = true;
          model = "go/glm-5.2";
          provider = "opencode";
        };
        dock = "right";
        model_parameters = [ ];
        sidebar_side = "right";
        tool_permissions = {
          tools = {
            terminal = {
              always_allow = [
                {
                  pattern = "^grep\\b";
                }
                {
                  pattern = "^head\\b";
                }
                {
                  pattern = "^wc\\b";
                }
              ];
            };
          };
        };
      };
      agent_servers = {
        github-copilot-cli = {
          type = "registry";
        };
      };
      auto_install_extensions = {
        basher = true;
        dockerfile = true;
        html = true;
        markdownlint = true;
        "material-icon-theme" = true;
        nix = true;
        "rainbow-csv" = true;
        terraform = true;
      };
      autosave = {
        after_delay = {
          milliseconds = 1000;
        };
      };
      buffer_font_fallbacks = [ "Fira Code" ];
      buffer_font_family = "Iosevka Nerd Font";
      buffer_font_size = config.fontcfg.sizes.applications + 4.5;
      buffer_font_weight = 500;
      buffer_line_height = {
        custom = 1.25;
      };
      collaboration_panel = {
        dock = "left";
      };
      diagnostics = {
        include_warnings = true;
        inline = {
          enabled = true;
          max_severity = null;
          min_column = 0;
          padding = 4;
        };
      };
      edit_predictions = {
        copilot = {
          enable_next_edit_suggestions = true;
        };
        mode = "eager";
      };
      git_panel = {
        dock = "left";
        group_by = "staging";
        sort_by = "name";
        tree_view = true;
      };
      gutter = {
        line_numbers = true;
      };
      icon_theme = "Material Icon Theme";
      inlay_hints = {
        enabled = true;
        show_background = false;
        show_other_hints = true;
        show_parameter_hints = true;
        show_type_hints = false;
        show_value_hints = true;
      };
      language_models = {
        opencode = {
          show_free_models = false;
          show_zen_models = false;
        };
      };
      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
          show_edit_predictions = true;
        };
        TypeScript = {
          code_actions_on_format = {
            "source.addMissingImports.ts" = true;
            "source.fixAll.ts" = true;
            "source.organizeImports" = true;
            "source.removeUnused.ts" = true;
            "source.sortImports" = true;
          };
          enable_language_server = true;
          format_on_save = "on";
          language_servers = [ "vtsls" ];
          prettier = {
            allowed = true;
          };
          remove_trailing_whitespace_on_save = true;
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
              command = [ "nixfmt" ];
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
      project_panel = {
        dock = "left";
      };
      relative_line_numbers = "enabled";
      show_edit_predictions = true;
      terminal = {
        font_fallbacks = [ "Fira Code" ];
        font_family = config.fontcfg.monospace.name;
        font_size = config.fontcfg.sizes.terminal + 3.5;
      };
      theme = "Ayu Dark";
      ui_font_family = config.fontcfg.monospace.name;
      ui_font_size = config.fontcfg.sizes.terminal + 4.5;
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
