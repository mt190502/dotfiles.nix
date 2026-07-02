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
          "@isfeng/easydict-0": {
             "preferences": {
                "bingHost": "",
                "deepLEndpoint": "",
                "enableAppleTranslate": false,
                "enableAutomaticPlayWordAudio": true,
                "enableAutomaticQuerySelectedText": true,
                "enableBaiduLanguageDetect": true,
                "enableBaiduTranslate": false,
                "enableBingTranslate": true,
                "enableCaiyunTranslate": false,
                "enableDeepLTranslate": true,
                "enableDeepLXTranslate": false,
                "enableDetectLanguageSpeedFirst": true,
                "enableGeminiTranslate": false,
                "enableGoogleTranslate": false,
                "enableLingueeDictionary": false,
                "enableOpenAITranslate": false,
                "enableSelectTargetLanguage": true,
                "enableSystemProxy": false,
                "enableTencentTranslate": false,
                "enableVolcanoTranslate": false,
                "enableYoudaoDictionary": false,
                "enableYoudaoTranslate": false,
                "forceMaxCompletionTokens": false,
                "geminiAPIURL": "https://generativelanguage.googleapis.com",
                "geminiModel": "gemini-2.0-flash",
                "language1": "en",
                "language2": "tr",
                "openAIAPIURL": "https://api.openai.com/v1/chat/completions",
                "openAIModel": "gpt-4o-mini",
                "servicesOrder": "",
                "showOpenInEudicFirst": false,
                "tencentSecretId": "",
                "volcanoAccessKeyId": ""
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

  getVicinaeExtensions =
    names:
    map (
      name:
      inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}.${name}.overrideAttrs (old: {
        npmFlags = (old.npmFlags or [ ]) ++ [ "--legacy-peer-deps" ];
      })
    ) names;
  raycastExtBuilder = inputs.self.legacyPackages.${pkgs.stdenv.hostPlatform.system}.raycastExtensions;
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
        ++ (builtins.attrValues (raycastExtBuilder [
          "1password"
          "chatgpt"
          "deepcast"
          # "easydict"
          "simple-dictionary"
          "tailscale"
          "word-count"
        ]));
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
