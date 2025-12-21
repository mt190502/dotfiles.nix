{
  config,
  lib,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  cfg = config.moduleopts.home-manager;

  rayCli = pkgs.fetchurl {
    url = "https://cli.raycast.com/1.86.0-alpha.65/linux/ray";
    sha256 = "sha256-UgDA2hIH7HwKl3j4UEGIlvh6eE+IWUlSML0wloHFPQw=";
  };

  getVicinaeExtensions =
    names:
    map (name: inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}.${name}) names;
  genRaycastExtensions =
    with pkgs;
    names:
    let
      raycastRepo = fetchFromGitHub {
        owner = "raycast";
        repo = "extensions";
        rev = "27c8726a793b985df4cc8f1a771e354e9c12b195";
        sha256 = "sha256-6VfYwnFEnKUvZsjqeUSPCY5FCiMxW5kxYp18REetffY=";
        sparseCheckout = map (name: "/extensions/${name}") names;
      };
    in
    map (
      name:
      buildNpmPackage rec {
        inherit name;
        src = raycastRepo + "/extensions/${name}";
        buildPhase = ''
          runHook preBuild
          mkdir -p node_modules/@raycast/api/bin/linux
          cp ${rayCli} node_modules/@raycast/api/bin/linux/ray
          chmod +x node_modules/@raycast/api/bin/linux/ray
          npm run build
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out/
          cp -r /build/.config/*/extensions/${name}/* $out/
          runHook postInstall
        '';
        npmConfigHook = importNpmLock.npmConfigHook;
        npmDeps = importNpmLock { npmRoot = src; };
      }
    ) names;
in
{
  config = lib.mkIf (cfg.preferred.menu == "vicinae") {
    programs.vicinae = {
      enable = true;
      package = pkgs-unstable.vicinae;
      systemd = {
        enable = true;
        autoStart = true;
      };
      extensions =
        (getVicinaeExtensions [
          "bluetooth"
          "nix"
          "ssh"
          "stocks"
        ])
        ++ (genRaycastExtensions [
          "1password"
          "chatgpt"
          "tailscale"
          "word-count"
        ]);
      themes = {
        stylix = with config.stylix; {
          meta = {
            version = 1;
            name = "Stylix";
            description = "Stylix theme for Vicinae";
            variant = if polarity == "either" then "light" else polarity;
          };
          colors =
            with config.stylix.customColors.withHashtag;
            with config.lib.stylix.colors.withHashtag;
            {
              core = {
                inherit background border;
                accent = active;
                foreground = text;
                secondary_background = inactive;
              };
              accents = {
                blue = base0D;
                cyan = base0C;
                green = base0B;
                magenta = base0E;
                orange = base09;
                purple = base0E;
                red = base08;
                yellow = base0A;
              };
              list.item = {
                selection = {
                  background.name = base02;
                  secondary_background = base03;
                };
                hover.background = base01;
              };
            };
        };
      };
    };
  };
}
