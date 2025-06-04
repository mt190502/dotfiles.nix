{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.wofi;
in
{
  options.moduleopts.home-manager.wofi = {
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
      style = with config.stylix.customColors.withHashtag; ''
        #inner-box,
        #outer-box,
        #input,
        #text {
        	margin: 5px;
        	background-color: ${background};
        }

        #window {
        	border: 4px solid ${border};
        	border-radius: 5px;
        	color: ${text};
        }

        #input {
        	border: 2px solid ${border};
        }

        #text {
        	color: ${text};
        	font-size: ${builtins.toString (config.stylix.fonts.sizes.applications + 6)}px;
        }

        #entry:selected,
        #img:selected,
        #text:selected {
        	background-color: ${border};
          color: ${background};
        }
      '';
    };
  };
}
