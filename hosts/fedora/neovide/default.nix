{ config, ... }:

{
  programs.neovide = {
    enable = true;
    package = config.wrappedPkgs.neovide;
    settings = {
      font = {
        normal = [ config.stylix.fonts.monospace.name ];
        size = config.stylix.fonts.sizes.terminal;
      };
      wsl = false;
    };
  };
  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
      };
    };

    plugins = {
      avante = {
        enable = true;
        settings = {
          auto_suggestions_provider = "copilot";
          cursor_applying_provider = "copilot";
          behaviour = {
            auto_suggestions = true;
            auto_apply_diff_after_generation = true;
            enable_cursor_planning_mode = true;
          };
          provider = "copilot";
          copilot = {
            model = "o3-mini";
          };
          suggestion = {
            debounce = 800;
          };
        };
      };

      cmp = {
        enable = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        autoEnableSources = true;
      };

      colorizer = {
        enable = true;
      };

      copilot-lua = {
        enable = true;
      };

      dashboard = {
        enable = true;
      };

      lualine = {
        enable = true;
        settings = {
          options = {
            component_separators = "";
            section_separators = {
              left = "";
              right = "";
            };
          };
        };
      };

      nvim-tree = {
        enable = true;
        openOnSetup = true;
        respectBufCwd = true;
      };

      treesitter = {
        enable = true;
        settings = {
          highlight = {
            enable = true;
          };
        };
      };

      web-devicons = {
        enable = true;
      };
    };

    opts = {
      expandtab = true;
      incsearch = false;
      number = true;
      shiftwidth = 4;
      signcolumn = "yes";
      smartindent = true;
      tabstop = 4;
      termguicolors = true;
      updatetime = 300;
    };
  };
}
