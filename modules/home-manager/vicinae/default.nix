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
  settings = ''
    {
       "theme": {
          "dark": {
             "name": "stylix",
             "icon_theme": "Flat-Remix-Blue-Dark"
          }
       },
       "favorites": [
          "applications:org.kde.dolphin",
          "applications:org.equicord.equibop",
          "applications:io.github.ungoogled_software.ungoogled_chromium",
          "applications:io.gitlab.librewolf-community",
          "applications:com.valvesoftware.Steam",
          "applications:md.obsidian.Obsidian",
          "applications:com.github.tchx84.Flatseal",
          "applications:com.stremio.Stremio",
          "applications:org.gnome.Calculator",
          "applications:org.signal.Signal",
          "applications:org.gnome.TextEditor"
       ],
       "launcher_window": {
         "layer_shell": {
           "enabled": true,
           "keyboard_interactivity": "exclusive",
           "layer": "top"
         }
       },
       "providers": {
          "@abielzulio/chatgpt": {
             "preferences": {
                "apiEndpoint": "https://litellm.core.xeome.dev/v1",
                "useApiEndpoint": true
             }
          },
          "@khasbilegt/1password": {
             "preferences": {
                "cliPath": "/usr/local/bin/op",
                "zshPath": "/usr/sbin/fish"
             }
          },
          "@leiserfg/ssh-0": {
             "preferences": {
                "terminal": "alacritty"
             }
          },
          "@samlinville/tailscale": {
             "preferences": {
                "tailscalePath": "/usr/sbin/tailscale"
             }
          },
          "clipboard": {
             "preferences": {
                "encryption": false,
                "monitoring": true
             }
          },
          "core": {
             "entrypoints": {
                "documentation": {
                   "enabled": false
                },
                "oauth-token-store": {
                   "enabled": false
                },
                "open-config-file": {
                   "enabled": false
                },
                "open-default-config": {
                   "enabled": false
                },
                "report-bug": {
                   "enabled": false
                },
                "sponsor": {
                   "enabled": false
                }
             }
          },
          "manage-shortcuts": {
             "enabled": false
          },
          "power": {
             "enabled": false
          }
       }
    }
  '';

  rayCli = pkgs.fetchurl {
    url = "https://cli.raycast.com/1.86.0-alpha.65/linux/ray"; #~ https://cli.raycast.com/latest_version.txt
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
        rev = "0618837c0055603bac192ffdc5410e2c3eaff84c";
        sha256 = "sha256-mDgQmymbZ+5CWNW4koOzV23S05rXPxInA3+buw2rfsg=";
        sparseCheckout = map (name: "/extensions/${name}") names;
      };
    in
    map (
      name:
      buildNpmPackage rec {
        inherit name;
        inherit (importNpmLock) npmConfigHook;
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
      settings = {
        closeOnFocusLoss = false;
        considerPreedit = false;
        faviconService = "google";
        font = {
          size = 10.5;
        };
        keybinding = "default";
        popToRootOnClose = true;
        rootSearch = {
          searchFiles = false;
        };
        theme = {
          iconTheme = "Flat-Remix-Blue-Dark";
          name = "stylix";
        };
        window = lib.mkDefault {
          csd = true;
          opacity = 1;
          rounding = 10;
        };
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
        stylix =
          with config.stylix;
          lib.mkDefault {
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
    home.activation.vicinaeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        target="${config.xdg.configHome}/vicinae/settings.json"
        [ ! -e "$target" ] && mkdir -p "$(dirname "$target")"
        cat >"$target" <<'EOF'
      ${settings}
      EOF
    '';
  };
}
