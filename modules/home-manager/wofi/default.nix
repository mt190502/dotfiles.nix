{
  config,
  lib,
  ...
}:

let
  cfg = config.moduleopts.wofi;
in
{
  options.moduleopts.wofi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "wofi";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;

      settings = {
        allow_images = true;
        height = "40%";
        insenstive = true;
        key_expand = "Tab";
        line_wrap = "word_char";
        mode = "dmenu";
        no_actions = true;
        term = lib.getExe config.wrapped.alacritty;
        width = "40%";
      };

      style = ''
        #inner-box,
        #outer-box,
        #input,
        #text {
        	margin: 5px;
        	background-color: ${config.colors.backgroundColor};
        }

        #window {
        	border: 4px solid ${config.colors.activeColor};
        	border-radius: 5px;
        	color: ${config.colors.textColor};
        }

        #input {
        	border: 2px solid ${config.colors.activeColor};
        }

        #text {
        	color: ${config.colors.textColor};
        	font-size: ${builtins.toString (config.stylix.fonts.sizes.applications + 6)}px;
        }

        #entry:selected,
        #img:selected,
        #text:selected {
        	background-color: ${config.colors.activeColor};
        }
      '';
    };
  };
}
