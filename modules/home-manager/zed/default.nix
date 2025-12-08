{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.zed;
in
{
  options.moduleopts.home-manager.zed = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Zed editor";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      userSettings = {
        agent = {
          default_model = {
            provider = "LiteLLM";
            model = "taha-claude-sonnet-4.5";
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
        buffer_font_size = config.stylix.fonts.sizes.applications + 4.5;
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
        language_models = {
          openai_compatible = {
            LiteLLM = {
              api_url = "https://litellm.core.xeome.dev/v1";
              available_models = [
                {
                  name = "taha-claude-sonnet-4.5";
                  max_tokens = 1000000;
                  max_output_tokens = 64000;
                  max_completion_tokens = 200000;
                  capabilities = {
                    tools = true;
                    images = true;
                    parallel_tool_calls = true;
                    prompt_cache_key = true;
                  };
                }
                {
                  name = "taha-gemini-2.5-pro";
                  max_tokens = 1000000;
                  max_output_tokens = 65535;
                  max_completion_tokens = 200000;
                  capabilities = {
                    tools = true;
                    images = true;
                    parallel_tool_calls = true;
                    prompt_cache_key = true;
                  };
                }
                {
                  name = "taha-gpt-4.1";
                  max_tokens = 1051200;
                  max_output_tokens = 32768;
                  max_completion_tokens = 210240;
                  capabilities = {
                    tools = true;
                    images = true;
                    parallel_tool_calls = true;
                    prompt_cache_key = true;
                  };
                }
                {
                  name = "taha-gpt-5.1";
                  max_tokens = 400000;
                  max_output_tokens = 128000;
                  max_completion_tokens = 20000;
                  capabilities = {
                    tools = true;
                    images = true;
                    parallel_tool_calls = true;
                    prompt_cache_key = true;
                  };
                }
                {
                  name = "taha-gpt-5.1-codex";
                  max_tokens = 400000;
                  max_output_tokens = 128000;
                  max_completion_tokens = 20000;
                  capabilities = {
                    tools = true;
                    images = true;
                    parallel_tool_calls = true;
                    prompt_cache_key = true;
                  };
                }
              ];
            };
          };
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
          font_family = config.stylix.fonts.monospace.name;
          font_fallbacks = [
            "Fira Code"
            "Droid Sans"
            "Droid Sans Fallback"
          ];
          font_size = config.stylix.fonts.sizes.terminal + 3.5;
        };
        theme = "Ayu Dark";
        ui_font_family = config.stylix.fonts.monospace.name;
        ui_font_size = config.stylix.fonts.sizes.terminal + 4.5;
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
  };
}
