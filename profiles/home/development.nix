## ------------------------------------------------------------------------------------ ##
#  Development Tools Bundle                                                              #
## ------------------------------------------------------------------------------------ ##
{
  lib,
  pkgs,
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
      with pkgs;
      [
        age
        binwalk
        dig
        delta
        gnumake
        gping
        hyperfine
        iftop
        inetutils
        iperf
        jq
        just
        mongodb-tools
        mongosh
        netcat
        nix-inspect
        nixd
        nixfmt
        nmap
        onefetch
        postgresql_18
        shellcheck
        sops
        testssl
        yq-go
      ]
      ++ lib.optionals (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system) [
        siege
        strace
        traceroute
      ];

    sessionVariables = {
      GOPATH = "$HOME/.go";
    };
  };
}
