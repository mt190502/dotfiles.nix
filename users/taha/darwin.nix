{
  inputs,
  flakeName,
  system,
  pkgs,
  pkgs-unstable,
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
        inputs
        flakeName
        system
        pkgs-unstable
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
      ++ (with inputs.self.homeProfiles; [
        ai
        cloud
        development
        neovim
        tmux
      ]);
    };
  };
}
