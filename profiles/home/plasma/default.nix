{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];
  config = {
    preferences.desktopenv = lib.mkDefault "plasma";
    programs.plasma = {
      enable = true;
      desktop = {
        icons = {
          alignment = "left";
          arrangement = "topToBottom";
          folderPreviewPopups = false;
          previewPlugins = [
            "audiothumbnail"
            "fontthumbnail"
          ];
        };
      };
      fonts = {
        general = {
          family = config.fontcfg.serif.name;
          pointSize = config.fontcfg.sizes.applications;
          styleStrategy.antialiasing = "prefer";
        };
        fixedWidth = {
          family = config.fontcfg.monospace.name;
          pointSize = config.fontcfg.sizes.applications;
          styleStrategy.antialiasing = "prefer";
        };
        small = {
          family = config.fontcfg.serif.name;
          pointSize = (config.fontcfg.sizes.applications - 2);
          styleStrategy.antialiasing = "prefer";
        };
        toolbar = {
          family = config.fontcfg.serif.name;
          pointSize = config.fontcfg.sizes.applications;
          styleStrategy.antialiasing = "prefer";
        };
        menu = {
          family = config.fontcfg.serif.name;
          pointSize = config.fontcfg.sizes.applications;
          styleStrategy.antialiasing = "prefer";
        };
        windowTitle = {
          family = config.fontcfg.serif.name;
          pointSize = config.fontcfg.sizes.applications;
          styleStrategy.antialiasing = "prefer";
        };
      };
      # hotkeys = {}; #~ todo: add hotkeys
      input = {
        keyboard = {
          layouts = [
            {
              layout = "us";
            }
            {
              layout = "tr";
            }
          ];
          numlockOnStartup = "on";
          options = [
            "grp:win_space_toggle"
          ];
          switchingPolicy = "global";
        };
      };
      krunner = {
        activateWhenTypingOnDesktop = true;
        historyBehavior = "enableSuggestions";
        position = "center";
        shortcuts = {
          launch = "Meta+d";
          runCommandOnClipboard = "Meta+v";
        };
      };
      kscreenlocker = {
        appearance = {
          alwaysShowClock = true;
          showMediaControls = true;
        };
        lockOnResume = true;
        lockOnStartup = false;
        passwordRequired = true;
        passwordRequiredDelay = 120;
        timeout = 60;
      };
      kwin = {
        cornerBarrier = true;
        edgeBarrier = 50;
        effects = {
          blur.enable = true;
          hideCursor = {
            hideOnInactivity = 10;
            hideOnTyping = true;
          };
          minimization = {
            animation = "magiclamp";
          };
          shakeCursor.enable = true;
          windowOpenClose.animation = "scale";
        };
        nightLight = {
          enable = true;
          mode = "times";
          temperature = {
            day = 4000;
            night = 3000;
          };
          time = {
            evening = "19:00";
            morning = "07:00";
          };
          transitionTime = 15;
        };
        # tiling.layout = ""; #~ todo: add tiling layout
        titlebarButtons = {
          left = [
            "more-window-actions"
          ];
          right = [
            "minimize"
            "maximize"
            "close"
          ];
        };
        virtualDesktops = {
          names = map (i: "Desktop ${toString i}") (lib.range 1 10);
          number = 10;
          rows = 1;
        };
      };
      panels = [
        {
          alignment = "center";
          floating = false;
          height = 32;
          location = "top";
          opacity = "translucent";
          widgets = [
            "org.kde.plasma.kickoff"
            #~ todo: add appmenu widget here
            "org.kde.plasma.appmenu"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.systemtray"
          ];
        }
        {
          alignment = "center";
          floating = true;
          height = 48;
          lengthMode = "fit";
          location = "bottom";
          opacity = "translucent";
          widgets = [
            "org.kde.plasma.icontasks"
          ];
        }
      ];
      session = {
        sessionRestore = {
          excludeApplications = [
            "firefox"
          ];
          restoreOpenApplicationsOnLogin = "startWithEmptySession";
        };
      };
      # shortcuts = { }; #~ todo: add global shortcuts
      spectacle = {
        shortcuts = {
          captureActiveWindow = "Meta+Shift+a";
          captureCurrentMonitor = "Print";
          captureEntireDesktop = null;
          captureRectangularRegion = "Meta+Shift+s";
          captureWindowUnderCursor = null;
          launch = null;
          launchWithoutCapturing = null;
          recordRegion = null;
          recordScreen = null;
          recordWindow = null;
        };
      };
      windows.allowWindowsToRememberPositions = true;
      workspace = {
        enableMiddleClickPaste = true;
        clickItemTo = "select";
        colorScheme = "BreezeDark";
        cursor = {
          animationTime = null;
          cursorFeedback = "None";
          size = 32;
          taskManagerFeedback = true;
          theme = "Adwaita";
        };
        iconTheme = "Flat-Remix-Blue-Dark";
        lookAndFeel = "org.kde.breezedark.desktop";
        soundTheme = "ocean";
        theme = "breeze-dark";
        tooltipDelay = 5;
        wallpaperBackground.blur = true;
        wallpaperFillMode = "stretch";
        widgetStyle = "breeze";
        windowDecorations = {
          library = "org.kde.breeze";
          theme = "Breeze";
        };
      };
    };
  };
}
