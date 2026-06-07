{
  config,
  lib,
  inputs,
  osConfig ? null,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  settings = ''
    {
       "close_on_focus_loss": false,
       "pop_to_root_on_close": true,
       "favicon_service": "google",
       "search_files_in_root": true,
       "theme": {
          "dark": {
             "name": "stylix",
             "icon_theme": "${config.iconthemecfg.dark}"
          }
       },
       "favorites": [
          "applications:org.kde.dolphin",
          "applications:org.equicord.equibop",
          "applications:equibop",
          "applications:io.github.ungoogled_software.ungoogled_chromium",
          "applications:io.gitlab.librewolf-community",
          "applications:librewolf",
          "applications:com.valvesoftware.Steam",
          "applications:steam",
          "applications:md.obsidian.Obsidian",
          "applications:com.github.tchx84.Flatseal",
          "applications:com.stremio.Stremio",
          "applications:org.gnome.Calculator",
          "applications:org.signal.Signal",
          "applications:signal",
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
          "@CT-7567/simple-dictionary": {
            "entrypoints": {
              "search": {
                "preferences": {
                  "default_language": "en"
                }
              }
            }
          },
          "@khasbilegt/1password": {
             "preferences": {
                "cliPath": "${
                  if osConfig != null then "/run/wrappers/bin/op" else "/usr/local/bin/op"
                }",
                "zshPath": "${
                  if osConfig != null then "/run/current-system/sw/bin/fish" else "/usr/bin/fish"
                }"
             }
          },
          "@leiserfg/ssh-0": {
             "preferences": {
                "terminal": "${config.preferences.terminal}"
             }
          },
          "@mooxl/deepcast": {
             "preferences": {
                "closeRaycastAfterTranslation": false,
                "defaultFormality": "default",
                "defaultTargetLanguage": "TR",
                "onTranslateAction": "view",
                "returnToRootState": false,
                "showFormalityConfig": false,
                "showTransliteration": "whenProvided",
                "source": "selected"
             }
          },
          "@samlinville/tailscale": {
             "preferences": {
                "tailscalePath": "${lib.getExe pkgs.tailscale}"
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
    url = "https://cli.raycast.com/1.86.0-alpha.65/linux/ray"; # ~ https://cli.raycast.com/latest_version.txt
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
        rev = "e7c04a122cdde3ed58bf5184e2424808153644ad";
        sha256 = "sha256-iqXLoPWsSpND418UoDaOTPEzTIjRfIvw12snDAVK6M4=";
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
  config = {
    preferences.menu = lib.mkDefault "vicinae";
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
          "deepcast"
          "simple-dictionary"
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
