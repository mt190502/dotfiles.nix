{
  config,
  lib,
  pkgs,
  ...
}:

let
  _1password-native-messaging-host =
    pkgs.writeTextDir "lib/mozilla/native-messaging-hosts/com.1password.1password.json"
      (
        builtins.toJSON {
          name = "com.1password.1password";
          description = "1Password BrowserSupport";
          path = "/run/wrappers/bin/1Password-BrowserSupport";
          type = "stdio";
          allowed_extensions = [
            "{0a75d802-9aed-41e7-8daa-24c067386e82}"
            "{25fc87fa-4d31-4fee-b5c1-c32a7844c063}"
            "{d634138d-c276-4fc8-924b-40a0ea21d284}"
          ];
        }
      );
in
{
  programs.librewolf = {
    enable = true;
    nativeMessagingHosts = [ _1password-native-messaging-host ];
    policies.SearchEngines.Remove = [
      "Bing"
      "Mojeek"
      "Startpage"
    ];
    profiles = {
      main = {
        isDefault = true;
        containers = {
          personal = {
            id = 1;
            name = "Personal";
            color = "blue";
            icon = "fingerprint";
          };
          banking = {
            id = 2;
            name = "Banking";
            color = "turquoise";
            icon = "dollar";
          };
          shopping = {
            id = 3;
            name = "Shopping";
            color = "green";
            icon = "cart";
          };
          work = {
            id = 4;
            name = "Work";
            color = "orange";
            icon = "briefcase";
          };
          education = {
            id = 5;
            name = "Education";
            color = "orange";
            icon = "chill";
          };
          social = {
            id = 6;
            name = "Social";
            color = "red";
            icon = "food";
          };
          other = {
            id = 7;
            name = "Other";
            color = "pink";
            icon = "fence";
          };
        };
        containersForce = true;
        search = {
          force = true;
          default = "ddg-noai";
          engines = {
            ddg = {
              name = "DuckDuckGo";
              icon = "https://duckduckgo.com/favicon.ico";
              definedAliases = [
                "@d"
                "@ddg"
                "@g"
                "g"
                "@goog"
                "goog"
                "google"
              ];
              urls = [
                {
                  template = "https://duckduckgo.com/";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            ddg-noai = {
              name = "DuckDuckGo (No AI)";
              icon = "https://duckduckgo.com/favicon.ico";
              definedAliases = [
                "@dnoai"
                "@ddgnoai"
                "@gnoai"
                "gn"
                "@goognoai"
                "googno"
                "googlenoai"
              ];
              urls = [
                {
                  template = "https://duckduckgo.com/";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                    {
                      name = "ia";
                      value = "web";
                    }
                  ];
                }
              ];
            };
            github = {
              name = "GitHub";
              icon = "https://github.com/favicon.ico";
              definedAliases = [
                "@gh"
                "@github"
              ];
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            google = {
              name = "Google";
              icon = "https://www.google.com/favicon.ico";
              definedAliases = [
                "@gg"
                "gg"
              ];
              urls = [
                {
                  template = "https://www.google.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            nio = {
              name = "Nix Options";
              definedAliases = [
                "@nio"
                "@nixopt"
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "type";
                      value = "options";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            nip = {
              name = "Nix Packages";
              definedAliases = [
                "@nip"
                "@nixpkgs"
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            sxng = {
              name = "SearxNG";
              icon = "https://paulgo.io/static/themes/simple/img/favicon.svg";
              definedAliases = [
                "sx"
                "sxng"
                "@sxng"
                "@searxng"
              ];
              urls = [
                {
                  template = "https://paulgo.io/";
                  params = [
                    {
                      name = "preferences";
                      value = "eJx1WMmS47wNfpr4ooprJpOlcvApleQB8t9VEAlLHFGEmott9dMH0Epa3Yde9HEDsX6ggogteYPh1qJDD_ZiwbUJWrxBinSxpMDiDd1FPhUNo8WIt5aotXi5w8MocrXHQPaBfsMHjB3p23___cclwB0Dglfd7ecldjjgLRjZ5cKLko2h5vUOn3WE5vYfsAEvmsyxIwF_Xsm3l2VZHeJkV-EUuoi-BmtaN_D_6_qPhH6qjaujiTx1ARcZ5DC13HmqA1pU8faHT3jpKPY4hZvGO7BUl-RtfSc_QIzGtbfRY4zTRZsAjUVdo2uNY6X9-vuPdeN61d-f_vKvHaweRiOFul7-8tA_W2jrOpAyYKsBtQEGoVFu6lCuku0C6p5cthTsyEdW1rj0qkZQPduItzZRxpyDUMmR5oF1fTcW5yUuQC3KnT_GvhqM9-S3RSOrs-LfVYjkcd8K2KIa1k9nXhSqp-nNNu6jUfz_IMcv3yFCNKzYA2zA6JRfZgaqZfx9XtWDuW_nNcYa-cku3rABKrnEfpUZOem2MVF1KWIJNUn1GLfdCbz2CLpUdQG_GacZm2Jq1KZtDxXTiI7dNGB2q3npVSl11bkwClQ3VazNN-MpTyF4vPPRyqBTuGBP_TAcFtnZE475p0re8_QpxzTip1xiSMGo-Xs2Dh9FHHteEN1W7OTGGbFZyBfLZsrS2aGRpTH62EPcQUOE4mTWs_y0VD2x-WbkZLNsrLBwsRvIscfpi98OMPJ0_i3yDfTbjKL1YxaHLU6Yy3GHEBuKBWScni15GHSHzt56DJ3ucQzNmj8MIAOxgzhw4iu28tiAtaUwC1ZqYkfPZ3rEKtA9PsFjpXmeipLWFq-6e-N6A3mo3ieniwOnKTNqCw24z8KmLZrPjrNnNgmdSeG4Hn9HovXIltMtNJtXk8YGfXuMIccEDdv38CpOIpoDMD9qLiVvkxg522XFRwuTpLMtrnJ4IA6mXHkdNB7k1zq545hEv2h-AfC1xycXjHA12zWNrUYKcbdQl1ouBu0d1JZDM6SSOAkYwxdDgRPBngXMoJvj8sZBJiz7tud4nbI7mw8z5UnytwkdHes5iXrwUyXKCyZzby4f7aMwsqUmRLz6TRCblNFFOoPWmbs49bY7l3dQI7h1xWAkhbEjVpZTx47SZ2fyg4bn0BQO74Q78E92DTduDuImgCzN6ilgnkzJWhi2oiFJGNj_x9RYo2BNbEc2ncetGLTEVi3lMgnM18NMlwLx3pRpccngJmx1ZTQvjp5pd81t6YafYnckrTr2iyytsfBcLx7bjvNVKk0DGLfse9T33TQfCXyfiz8D5wj5eIKLZV5ZoJNgnmKUmGbiQ_lNlqIwTMHEIiaZQ927ECsxZX5ioJYKBjADZ8kW-CTGAj-RlXQEGrMvlUK4jhOzy83NFGg9SWIZ0hoii0H-3JHFM-7NA9T0fEu9GXwWMR88C8ppbciqDvUTReJY7CU8Nn-JslXgy6T9MrGI95hCf667B3qWKhs7CZWNFTZPLnA2DN1x7gROY5GJF-R83oq_lbeHGTCP36dpinASptAQ9eEd_EhUOpKAgZJXZ3RENSfvb-AjpgUWMjbbu5z9oIkvUqBk755ziB27ksgYFT_JFXOHies319YqeubUlutBUUh__vr1j9dhbZ00ujx0Pp34SLadVKPRWCEj2yw3py0mno9kZZ6Q4DjN5aOBsFUWB4-Sus7A2VoLXBh_gc4Bn5qpxWHL_iOij6nJU-1MZ1nKXvjozO32oQlK-infZ2F84sSf7-jRSluXr1yawS65ty4ox7_IHrOTl0HzpJfpyXEurcLkyE1CvDYtp9eTC2C2w4OMnluq9f6P1KVHvt0MnE9e4JM2xdUG5tb5Dp8wSsEsugjPxrgW5uFadNTgJRC4mdms0rfXlrLyENAF5ZnCc6-b1WXmvMxWuBAvDduMX7j2FT3r3378GF8ZnZY0sXSVRZv3Mo88tpgcagXDeMS-zF5Jd3azWb3l91l7qsN7TypLRHy19xKiSShZ1aWNUmLyXIvHQeVyHZ3CNz3H6XCM00Bc-12muZ-ZQu7ak3Q7C43mYJ-fODIazYW59zn_NGM3Fd_xEHploYWtV-zkPSuuwle0l9FvqS-XFrLgc71wAUcvjey7WruVVy-sUxjYvSCWQ5vyy_V8WQg5g8RhmKqtsC4ZuGyZlxmJ2c13Y8KfvxuTnZmBnIcH7t9Ik_tm532YeVXHBfeLGfpgrC9udJM-nHkA7pZw6wY2QnmQ95I4hsi9V-Tmc-tARy0p85g04gvzvmnsmBW4fbZRvzknUk4UJcHhTCh33mGk8WD6mPHO1AxSerKDpnEL2ZnRFWRwpnjndAzaUNVwTx_ypwKPKc56XZ00cIWCjZMcfKejkR1GnoxUn9U4SpweSpUGbhJ64qJzt_Tc8pYsC04Ut-ef0KeG83vapiTudlLYbRGQbcMx-JWTB7JGc9PrF4fZ1DRBR0U6mCi9FbUd2V9KwFjOC8tDVpHPi9BlYK7T0jXkzyHitRxn15O288Evy8U2CElLi5ln123o7YniSV470-esk6I8NHzxfPWM0V9Nxkbm0nOuReenuRk-P7LFv26vX8dr6GgTl5ZwM25-V8L_cT9oZwJLvuZcr_q9CG1TpW-oeT7JLCaRtVAuqQxgVeKcSyKrRPK6Qmo3b11zvmKPiktjBvXyVPzkSiiLmZ1Jyajl8dYzYeOZF2bkHK-3_wPUdKOK";
                    }
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            youtube = {
              name = "YouTube";
              icon = "https://www.youtube.com/favicon.ico";
              definedAliases = [
                "@yt"
                "@youtube"
              ];
              urls = [
                {
                  template = "https://www.youtube.com/results";
                  params = [
                    {
                      name = "search_query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
          };
        };
        settings = {
          "browser.download.autohideButton" = true;
          "browser.newtabpage.activity-stream.feeds.topsites" = true;
          "browser.nova.enabled" = false;
          "browser.search.suggest.enabled" = true;
          "browser.search.suggest.enabled.private" = true;
          "browser.startup.homepage" = "https://red.mtaha.dev";
          "browser.startup.page" = 3;
          "browser.toolbars.bookmarks.visibility" = "newtab";
          # "browser.uiCustomization.navBarWhenVerticalTabs" = "[\"sidebar-button\",\"back-button\",\"forward-button\",\"stop-reload-button\",\"home-button\",\"library-button\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"developer-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"search-container\",\"customizableui-special-spring2\",\"downloads-button\",\"popupwindow_ettoolong-browser-action\",\"tab-session-manager_sienori-browser-action\",\"_testpilot-containers-browser-action\",\"firerss_mtaha_dev-browser-action\",\"simple-translate_sienori-browser-action\",\"_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action\",\"addon_darkreader_org-browser-action\",\"_73a6fe31-595d-460b-a920-fcc0f8843232_-browser-action\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action\",\"unified-extensions-button\",\"fxa-toolbar-menu-button\"]";
          #"browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"sponsorblocker_ajay_app-browser-action\",\"_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action\",\"_92e6fe1c-6e1d-44e1-8bc6-d309e59406af_-browser-action\",\"_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action\",\"firefox-extension_deepl_com-browser-action\",\"_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action\",\"_9a41dee2-b924-4161-a971-7fb35c053a4a_-browser-action\",\"enhancerforyoutube_maximerf_addons_mozilla_org-browser-action\",\"contaner-proxy_bekh-ivanov_me-browser-action\"],\"nav-bar\":[\"sidebar-button\",\"back-button\",\"forward-button\",\"stop-reload-button\",\"home-button\",\"library-button\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"developer-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"search-container\",\"customizableui-special-spring2\",\"downloads-button\",\"popupwindow_ettoolong-browser-action\",\"tab-session-manager_sienori-browser-action\",\"_testpilot-containers-browser-action\",\"firerss_mtaha_dev-browser-action\",\"simple-translate_sienori-browser-action\",\"_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action\",\"addon_darkreader_org-browser-action\",\"_73a6fe31-595d-460b-a920-fcc0f8843232_-browser-action\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action\",\"unified-extensions-button\",\"fxa-toolbar-menu-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[],\"vertical-tabs\":[\"tabbrowser-tabs\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"developer-button\",\"screenshot-button\",\"ublock0_raymondhill_net-browser-action\",\"_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action\",\"_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action\",\"_92e6fe1c-6e1d-44e1-8bc6-d309e59406af_-browser-action\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action\",\"firefox-extension_deepl_com-browser-action\",\"firerss_mtaha_dev-browser-action\",\"addon_darkreader_org-browser-action\",\"tab-session-manager_sienori-browser-action\",\"_73a6fe31-595d-460b-a920-fcc0f8843232_-browser-action\",\"_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action\",\"_9a41dee2-b924-4161-a971-7fb35c053a4a_-browser-action\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action\",\"popupwindow_ettoolong-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"_testpilot-containers-browser-action\",\"enhancerforyoutube_maximerf_addons_mozilla_org-browser-action\",\"simple-translate_sienori-browser-action\",\"contaner-proxy_bekh-ivanov_me-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"vertical-tabs\",\"toolbar-menubar\",\"TabsToolbar\",\"PersonalToolbar\",\"unified-extensions-area\"],\"currentVersion\":23,\"newElementCount\":4}";
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";
          "browser.urlbar.suggest.searches" = true;
          "font.name.serif.x-western" = config.fontcfg.serif.name;
          "font.size.variable.x-western" = lib.mkForce (config.fontcfg.sizes.applications + 6);
          "general.autoScroll" = true;
          "general.smoothScroll" = false;
          "media.eme.enabled" = true;
          "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
          "sidebar.main.tools" = "syncedtabs,history,bookmarks,firefox-extension@deepl.com";
          "sidebar.verticalTabs" = true;
        };
        userChrome = ''
          #personal-bookmarks toolbarbutton.bookmark-item{
              margin: 0 -3px !important;
          }
          #personal-bookmarks .bookmark-item > .toolbarbutton-text { display:none !important; }
          #personal-bookmarks toolbarbutton.bookmark-item:hover{
              margin: -1px 2px !important;
          }
          #personal-bookmarks .bookmark-item:hover > .toolbarbutton-text { display:inline-block !important; }
          .titlebar-spacer { display: none; }
        '';
      };
    };
    settings = {
      "browser.download.panel.shown" = true;
      "browser.sessionstore.restore_pinned_tabs_on_demand" = true;
      "browser.taskbarTabs.enabled" = true;
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "identity.fxaccounts.enabled" = true;
      "identity.fxaccounts.toolbar.accessed" = true;
      "identity.sync.tokenserver.uri" = "https://ffsync.mtaha.dev/1.0/sync/1.5";
      "network.trr.custom_uri" = "https://dns.adguard.com/dns-query";
      "network.trr.excluded-domains" = "cluster.local,ts.net";
      "network.trr.mode" = 2;
      "network.trr.uri" = "https://dns.adguard.com/dns-query";
      "privacy.clearOnShutdown_v2.cache" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "privacy.resistFingerprinting" = false;
      "privacy.sanitize.pending" = "[]";
      "privacy.sanitize.sanitizeOnShutdown" = false;
      "privacy.trackingprotection.allow_list.baseline.enabled" = true;
      "privacy.trackingprotection.allow_list.convenience.enabled" = true;
      "privacy.trackingprotection.allow_list.hasUserInteractedWithETPSettings" = true;
      "privacy.userContext.newTabContainerOnLeftClick.enabled" = true;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };
  };
}
