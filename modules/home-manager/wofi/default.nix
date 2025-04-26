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

      style = with config.lib.stylix.colors.withHashtag; ''
        #inner-box,
        #outer-box,
        #input,
        #text {
        	margin: 5px;
        	background-color: ${base00};
        }

        #window {
        	border: 4px solid ${base0D};
        	border-radius: 5px;
        	color: ${base05};
        }

        #input {
        	border: 2px solid ${base0D};
        }

        #text {
        	color: ${base05};
        	font-size: ${builtins.toString (config.stylix.fonts.sizes.applications + 6)}px;
        }

        #entry:selected,
        #img:selected,
        #text:selected {
        	background-color: ${base0D};
        }
      '';
    };
  };
}
