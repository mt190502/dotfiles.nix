{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  cfg = config.moduleopts.home-manager.cloud-tools;
  gke-plugins = pkgs.google-cloud-sdk.withExtraComponents (
    with pkgs.google-cloud-sdk.components;
    [
      gke-gcloud-auth-plugin
    ]
  );
  inherit (pkgs) ansible;
in
{
  options.moduleopts.home-manager.cloud-tools = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Cloud bundle for cloud operations.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs-unstable; [
        dive
      ])
      ++ (with pkgs; [
        ansible
        awscli2
        gke-plugins
        k0sctl
        krew
        kubecolor
        kubectl
        kubectl-cnpg
        kubectl-df-pv
        kubectl-explore
        kubectl-neat
        kubernetes-helm
        kubetail
        minikube
        opentofu
        pacemaker
        packer
        tofu-ls
        skopeo
        terraform
        terragrunt
      ]);
    programs.fish = {
      functions = {
        acx = {
          wraps = "aws configure list-profiles";
          body = ''
            if test (count $argv) -eq 0
              aws configure list-profiles
              return 1
            end
            set -gx AWS_PROFILE $argv[1]
          '';
        };
        k = {
          wraps = "kubectl";
          body = "kubecolor $argv";
        };
        kcx = {
          wraps = "kubectl config use-context";
          body = "kubecolor config use-context $argv";
        };
        mergekconf = ''
          function mergekconf -d "Merge multiple kubeconfig files into one"
            set -l kube_dir "$HOME/.kube"
            if not test -d "$kube_dir"
                echo "Directory not found: $kube_dir"
                return 1
            end

            set -l files_to_merge (find "$kube_dir" -type f -not -name "config" -not -path "*/cache/*")
            set -l all_configs "$kube_dir/config"

            for file in $files_to_merge
                set all_configs "$all_configs:$file"
            end
            set -gx KUBECONFIG "$all_configs"

            echo "Merging kubeconfigs into $kube_dir/config"
            if kubectl config view --flatten > "$kube_dir/config.tmp"
                mv "$kube_dir/config" $HOME/.oldkubeconf-$(date +%Y-%m-%d_%H-%M-%S)
                mv "$kube_dir/config.tmp" "$kube_dir/config"
                echo "Successfully merged kubeconfigs."
            else
                echo "Failed to merge kubeconfigs."
                rm -f "$kube_dir/config.tmp"
                return 1
            end

            for file in $files_to_merge
              if [ ! -z "$(cat $file | grep apiVersion)" ]
                 rm -f "$file"
              end
            end
            set -gx KUBECONFIG "$kube_dir/config"
          end
        '';
        scx = {
          wraps = "ls $HOME/.sops";
          body = ''
            if test (count $argv) -eq 0
              ls $HOME/.sops
              return 1
            end
            set -gx SOPS_AGE_KEY_FILE "$HOME/.sops/$argv[1]"
          '';
        };
      };
      shellAliases = {
        #~ Containers
        a = lib.getExe' ansible "ansible";
        ap = "clear; ${lib.getExe' ansible "ansible-playbook"}";
        d = "docker";
      };
      shellInit = ''
        #################################################
        #### Kubernetes
        #################################################
        set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin

        #################################################
        #### Docker
        #################################################
        if [ -n "$(command -v docker)" ]
          docker completion fish | source
        end
      '';
    };
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
