{
  config,
  inputs,
  flakeName,
  system,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  programs.fish.enable = true;
  users.users.berry = {
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets."berry/shadow".path;
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
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
    users.berry = {
      nixpkgs.config.allowUnfree = true;
      imports = [
        ./default.nix
      ]
      ++ (with inputs.self.homeModules; [
        fastfetch
        fish
      ])
      ++ (with inputs.self.homeProfiles; [
      ]);
    };
  };
}
