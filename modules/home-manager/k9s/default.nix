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

      skins = {
        "stylix" =
          let
            foreground = config.colors.textColor;
            background = config.colors.backgroundColor;
            active = config.colors.activeColor;
            inactive = config.colors.inactiveColor;
            inactive2 = config.colors.inactiveColor2;
            text = config.colors.textColor;
            urgent = config.colors.urgentColor;
          in
          {
            k9s = {
              body = {
                fgColor = text;
                bgColor = background;
                logoColor = active;
              };
              info = {
                fgColor = active;
                sectionColor = foreground;
              };
              help = {
                fgColor = text;
                keyColor = active;
                numKeyColor = inactive2;
                sectionColor = active;
              };
              dialog = {
                fgColor = active;
                bgColor = background;
                buttonFgColor = text;
                buttonBgColor = background;
                buttonFocusFgColor = background;
                buttonFocusBgColor = active;
                labelFgColor = active;
                fieldFgColor = text;
              };
              frame = {
                border = {
                  fgColor = active;
                  focusColor = active;
                };
                menu = {
                  fgColor = text;
                  keyColor = active;
                  numKeyColor = inactive2;
                };
                crumbs = {
                  fgColor = text;
                  bgColor = inactive;
                  activeColor = active;
                };
                status = {
                  newColor = active;
                  modifyColor = active;
                  errorColor = urgent;
                  highlightColor = active;
                  killColor = urgent;
                  completedColor = text;
                };
                title = {
                  fgColor = active;
                  bgColor = background;
                  highlightColor = inactive2;
                  counterColor = active;
                  filterColor = inactive2;
                };
              };
              views = {
                table = {
                  fgColor = foreground;
                  bgColor = background;
                  cursorFgColor = text;
                  cursorBgColor = background;
                  header = {
                    fgColor = foreground;
                    bgColor = background;
                    sorterColor = inactive;
                  };
                };
                xray = {
                  fgColor = foreground;
                  bgColor = background;
                  cursorColor = background;
                  graphicColor = active;
                  showIcons = false;
                };
                yaml = {
                  keyColor = active;
                  colonColor = active;
                  valueColor = text;
                };
                logs = {
                  fgColor = foreground;
                  bgColor = background;
                  indicator = {
                    fgColor = foreground;
                    bgColor = background;
                  };
                };
              };
            };
          };
      };
    };
  };
}
