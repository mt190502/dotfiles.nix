{
  config,
  lib,
  ...
}:

let
  cfg = config.moduleopts.k9s;
in
{
  options.moduleopts.k9s = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "k9s";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.k9s = {
      enable = true;

      aliases = {
        dp = "deployments";
        sec = "v1/secrets";
        jo = "jobs";
        cr = "clusterroles";
        crb = "clusterrolebindings";
        ro = "roles";
        rb = "rolebindings";
        np = "networkpolicies";
      };

      settings = {
        k9s = {
          liveViewAutoRefresh = false;
          screenDumpDir = "${config.home.homeDirectory}/.local/state/k9s/screen-dumps";
          refreshRate = 2;
          maxConnRetry = 5;
          readOnly = false;
          noExitOnCtrlC = false;
          portForwardAddress = "localhost";
          ui = {
            enableMouse = true;
            headless = false;
            logoless = false;
            crumbsless = false;
            reactive = false;
            noIcons = false;
            defaultsToFullScreen = false;
          };
          skipLatestRevCheck = false;
          disablePodCounting = false;
          shellPod = {
            image = "busybox:1.35.0";
            namespace = "default";
            limits = {
              cpu = "100m";
              memory = "100Mi";
            };
          };
          imageScans = {
            enable = false;
            exclusions = {
              namespaces = [ ];
              labels = { };
            };
          };
          logger = {
            tail = 100;
            buffer = 5000;
            sinceSeconds = -1;
            textWrap = false;
            disableAutoscroll = false;
            showTime = false;
          };
          thresholds = {
            cpu = {
              critical = 90;
              warn = 70;
            };
            memory = {
              critical = 90;
              warn = 70;
            };
          };
        };
      };

      # skins = {
      #   "stylix" = with config.lib.stylix.colors.withHashtag; {
      #     k9s = {
      #       body = {
      #         fgColor = base05;
      #         bgColor = base00;
      #         logoColor = base0D;
      #       };
      #       info = {
      #         fgColor = base0D;
      #         sectionColor = base05;
      #       };
      #       help = {
      #         fgColor = base05;
      #         keyColor = base0D;
      #         numKeyColor = base0A;
      #         sectionColor = base0D;
      #       };
      #       dialog = {
      #         fgColor = base0D;
      #         bgColor = base00;
      #         buttonFgColor = base05;
      #         buttonBgColor = base00;
      #         buttonFocusFgColor = base00;
      #         buttonFocusBgColor = base0D;
      #         labelFgColor = base0D;
      #         fieldFgColor = base05;
      #       };
      #       frame = {
      #         border = {
      #           fgColor = base0D;
      #           focusColor = base0D;
      #         };
      #         menu = {
      #           fgColor = base05;
      #           keyColor = base0D;
      #           numKeyColor = base0A;
      #         };
      #         crumbs = {
      #           fgColor = base05;
      #           bgColor = base02;
      #           activeColor = base0D;
      #         };
      #         status = {
      #           newColor = base0D;
      #           modifyColor = base0D;
      #           errorColor = base08;
      #           highlightColor = base0D;
      #           killColor = base08;
      #           completedColor = base05;
      #         };
      #         title = {
      #           fgColor = base0D;
      #           bgColor = base00;
      #           highlightColor = base0A;
      #           counterColor = base0D;
      #           filterColor = base0A;
      #         };
      #       };
      #       views = {
      #         table = {
      #           fgColor = base05;
      #           bgColor = base00;
      #           cursorFgColor = base00;
      #           cursorBgColor = base05;
      #           header = {
      #             fgColor = base05;
      #             bgColor = base00;
      #             sorterColor = base02;
      #           };
      #         };
      #         xray = {
      #           fgColor = base05;
      #           bgColor = base00;
      #           cursorColor = base00;
      #           graphicColor = base0D;
      #           showIcons = false;
      #         };
      #         yaml = {
      #           keyColor = base0D;
      #           colonColor = base0D;
      #           valueColor = base05;
      #         };
      #         logs = {
      #           fgColor = base05;
      #           bgColor = base00;
      #           indicator = {
      #             fgColor = base05;
      #             bgColor = base00;
      #           };
      #         };
      #       };
      #     };
      #   };
      # };
    };
  };
}
