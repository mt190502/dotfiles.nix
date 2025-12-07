{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager.development;
in
{
  options.moduleopts.home-manager.development = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "development";
    };
  };
  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = {
        CC = "clang";
        CXX = "clang++";
        GOPATH = "${config.home.homeDirectory}/.go";
      };
      packages =
        (with pkgs-unstable; [
          bun
          dive
          postgresql_18
        ])
        ++ (
          with pkgs;
          [
            air
            ansible
            binwalk
            cargo
            delta
            delve
            direnv
            gdb
            gef
            gnumake
            go
            gopls
            gping
            hugo
            hyperfine
            iftop
            iperf
            jq
            just
            k0sctl
            kubectl
            kubernetes-helm
            kubetail
            llvm
            llvmPackages.clang
            llvmPackages.clang-tools
            minikube
            netcat
            nixd
            nixfmt-rfc-style
            nmap
            nodejs
            onefetch
            opentofu
            pkg-config
            pnpm
            shellcheck
            testssl
            yq
            zola
          ]
          ++ (lib.optionals (lib.hasSuffix "linux" system) [
            siege
            strace
            traceroute
          ])
        );
    };
  };
}
