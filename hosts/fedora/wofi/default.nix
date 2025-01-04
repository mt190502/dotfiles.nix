{ config, lib, ... }:

{
  options.pkgconfig.wofi = {
    enable = lib.mkEnableOption "Enable wofi configuration.";
  };
  config.programs.wofi = {
    enable = config.pkgconfig.wofi.enable;

    settings = {
      allow_images = true;
      height = "40%";
      insenstive = true;
      key_expand = "Tab";
      line_wrap = "word_char";
      mode = "dmenu";
      no_actions = true;
      term = "alacritty";
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
      	color: #eefdff;
      }

      #input {
      	border: 2px solid ${config.colors.activeColor};
      }

      #text {
      	color: ${config.colors.textColor};
      	font-size: 16px;
      }

      #entry:selected,
      #img:selected,
      #text:selected {
      	background-color: ${config.colors.activeColor};
      }
    '';
  };
}
