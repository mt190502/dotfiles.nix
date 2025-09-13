{
  config,
  lib,
  pkgs,
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
      packages = with pkgs; [
        air
        ansible
        binwalk
        bun
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
        minio-client
        netcat
        nixd
        nixfmt-rfc-style
        nmap
        nodejs
        onefetch
        opentofu
        pkg-config
        pnpm
        postgresql_17
        shellcheck
        siege
        strace
        testssl
        traceroute
        yq
        zola
      ];
    };
  };
}
