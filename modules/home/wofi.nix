{ config, lib, ... }:

{
  config = {
    preferences.menu = lib.mkDefault "wofi";
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
