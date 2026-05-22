{ config, lib, pkgs, ... }:

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
        settings = {
          "browser.download.autohideButton" = true;
          "browser.newtabpage.activity-stream.feeds.topsites" = true;
          "browser.search.suggest.enabled" = true;
          "browser.urlbar.suggest.searches" = true;
          "browser.search.suggest.enabled.private" = true;
          "browser.startup.homepage" = "https://red.mtaha.dev";
          "browser.startup.page" = 3;
          "browser.toolbars.bookmarks.visibility" = "newtab";
          # "browser.uiCustomization.navBarWhenVerticalTabs" = "[\"sidebar-button\",\"back-button\",\"forward-button\",\"stop-reload-button\",\"home-button\",\"library-button\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"developer-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"search-container\",\"customizableui-special-spring2\",\"downloads-button\",\"popupwindow_ettoolong-browser-action\",\"tab-session-manager_sienori-browser-action\",\"_testpilot-containers-browser-action\",\"firerss_mtaha_dev-browser-action\",\"simple-translate_sienori-browser-action\",\"_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action\",\"addon_darkreader_org-browser-action\",\"_73a6fe31-595d-460b-a920-fcc0f8843232_-browser-action\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action\",\"unified-extensions-button\",\"fxa-toolbar-menu-button\"]";
          #"browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"sponsorblocker_ajay_app-browser-action\",\"_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action\",\"_92e6fe1c-6e1d-44e1-8bc6-d309e59406af_-browser-action\",\"_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action\",\"firefox-extension_deepl_com-browser-action\",\"_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action\",\"_9a41dee2-b924-4161-a971-7fb35c053a4a_-browser-action\",\"enhancerforyoutube_maximerf_addons_mozilla_org-browser-action\",\"contaner-proxy_bekh-ivanov_me-browser-action\"],\"nav-bar\":[\"sidebar-button\",\"back-button\",\"forward-button\",\"stop-reload-button\",\"home-button\",\"library-button\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"developer-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"search-container\",\"customizableui-special-spring2\",\"downloads-button\",\"popupwindow_ettoolong-browser-action\",\"tab-session-manager_sienori-browser-action\",\"_testpilot-containers-browser-action\",\"firerss_mtaha_dev-browser-action\",\"simple-translate_sienori-browser-action\",\"_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action\",\"addon_darkreader_org-browser-action\",\"_73a6fe31-595d-460b-a920-fcc0f8843232_-browser-action\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action\",\"unified-extensions-button\",\"fxa-toolbar-menu-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[],\"vertical-tabs\":[\"tabbrowser-tabs\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"developer-button\",\"screenshot-button\",\"ublock0_raymondhill_net-browser-action\",\"_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action\",\"_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action\",\"_92e6fe1c-6e1d-44e1-8bc6-d309e59406af_-browser-action\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action\",\"firefox-extension_deepl_com-browser-action\",\"firerss_mtaha_dev-browser-action\",\"addon_darkreader_org-browser-action\",\"tab-session-manager_sienori-browser-action\",\"_73a6fe31-595d-460b-a920-fcc0f8843232_-browser-action\",\"_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action\",\"_9a41dee2-b924-4161-a971-7fb35c053a4a_-browser-action\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action\",\"popupwindow_ettoolong-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"_testpilot-containers-browser-action\",\"enhancerforyoutube_maximerf_addons_mozilla_org-browser-action\",\"simple-translate_sienori-browser-action\",\"contaner-proxy_bekh-ivanov_me-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"vertical-tabs\",\"toolbar-menubar\",\"TabsToolbar\",\"PersonalToolbar\",\"unified-extensions-area\"],\"currentVersion\":23,\"newElementCount\":4}";
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";
          "font.name.serif.x-western" = config.fontcfg.serif.name;
          "font.size.variable.x-western" = lib.mkForce (config.fontcfg.sizes.applications + 6);
          "media.eme.enabled" = true;
          "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
          "general.autoScroll" = true;
          "general.smoothScroll" = false;
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
      "network.trr.custom_uri" = "https://dns.mtaha.dev/dns-query";
      "network.trr.mode" = 2;
      "network.trr.uri" = "https://dns.mtaha.dev/dns-query";
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
