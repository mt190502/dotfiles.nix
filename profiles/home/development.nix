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
        mongosh
        postgresql_18
      ])
      ++ (
        with pkgs;
        [
          age
          air
          binwalk
          cargo
          dig
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
          inetutils
          iperf
          jq
          just
          llvm
          llvmPackages.clang
          llvmPackages.clang-tools
          netcat
          tokstat
          mongodb-tools
          nix-inspect
          nixd
          nixfmt
          nmap
          nodejs
          onefetch
          pkg-config
          pnpm
          shellcheck
          sops
          testssl
          uv
          yq-go
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
