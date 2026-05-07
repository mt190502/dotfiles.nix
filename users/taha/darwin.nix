{
  flakeName,
  inputs,
  pkgs,
  pkgs-unstable,
  sharing,
  system,
  ...
}:

rec {
  programs.fish.enable = true;
  users.users.taha = {
    shell = pkgs.fish;
    home = "/Users/taha";
    uid = 502;
  };
  home-manager = {
    useGlobalPkgs = false;
    extraSpecialArgs = {
      inherit
        flakeName
        inputs
        pkgs-unstable
        sharing
        system
        ;
    };
    users.taha = {
      home.homeDirectory = users.users.taha.home;
      nixpkgs.config.allowUnfree = true;
      imports = [
        ./default.nix
      ]
      ++ (with inputs.self.homeModules; [
        delta
        direnv
        fastfetch
        fish
        fontconfig
        git
        mpv
        ytdlp
        zed
      ])
      ++ (with sharing.profiles.home; [
        ai
        cloud
        development
        neovim
        tmux
      ]);
    };
  };
}
