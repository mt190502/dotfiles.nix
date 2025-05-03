{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.moduleopts.neovide;
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  options.moduleopts.neovide = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "neovide";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovide = {
      enable = true;
      package = config.wrapped.neovide;
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
        colorizer.enable = true;
        copilot-lua.enable = true;
        dashboard.enable = true;
        web-devicons.enable = true;


        cmp = {
          enable = true;
          settings.sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          autoEnableSources = true;
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
  };
}
