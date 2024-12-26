{ config, lib, ... }:

{
  options.pkgconfig.wofi = {
    enable = lib.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable wofi configuration.";
    };
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
      	background-color: #12100c;
      }

      #window {
      	border: 4px solid #5b9fcb;
      	border-radius: 5px;
      	color: #eefdff;
      }

      #input {
      	border: none;
      	border-bottom: 2px solid #5b9fcb;
      }

      #text {
      	color: #eefdff;
      	font-size: 16px;
      }

      #entry:selected,
      #img:selected,
      #text:selected {
      	background-color: #3e6d8c;
      }
    '';
  };
}
