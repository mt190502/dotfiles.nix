## ------------------------------------------------------------------------------------ ##
#  Development Tools Bundle                                                              #
## ------------------------------------------------------------------------------------ ##
{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  ########################################
  #
  ## General Packages
  #
  ########################################
  home = {
    packages =
      (with pkgs-unstable; [
        bun
        postgresql_18
      ])
      ++ (
        with pkgs;
        [
          air
          binwalk
          cargo
          delta
          delve
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
          llvm
          llvmPackages.clang
          llvmPackages.clang-tools
          netcat
          nixd
          nixfmt-rfc-style
          nmap
          nodejs
          onefetch
          pkg-config
          pnpm
          shellcheck
          sops
          testssl
          yq
          zola
        ]
        ++ (lib.optionals (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system) [
          siege
          strace
          traceroute
        ])
      );

    sessionVariables = {
      CC = "clang";
      CXX = "clang++";
      GOPATH = "$HOME/.go";
    };
  };
}
