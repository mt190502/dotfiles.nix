{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  cfg = config.moduleopts.home-manager.k9s;
in
{
  options.moduleopts.home-manager.k9s = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "k9s";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.k9s = {
      enable = true;
      package = pkgs-unstable.k9s;
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
    };
  };
}
