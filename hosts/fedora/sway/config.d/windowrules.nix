{ ... }:

{
  wayland.windowManager.sway.config = {
    floating.criteria = [
      {
        app_id = "(firefox|LibreWolf)";
        title = "^(.*)Sharing Indicator(.*)";
      }
      {
        app_id = "(firefox|LibreWolf)";
        title = "^Extension:(.*)";
      }
      {
        app_id = "(firefox|LibreWolf)";
        title = "^Library$";
      }
      {
        app_id = "(firefox|LibreWolf)";
        title = "^Picture-in-Picture(.*)$";
      }
      {
        app_id = "Alacritty";
        title = "nmtui";
      }
      {
        app_id = "Alacritty";
        title = "wttr.in";
      }
      { app_id = "com.usebottles.bottles"; }
      {
        app_id = "flameshot";
        title = "flameshot";
      }
      { app_id = "nm-connection-editor$"; }
      { app_id = "org.freedesktop.impl.portal.desktop.kde"; }
      { app_id = "org.gnome.Calculator"; }
      { app_id = "org.kde.discover"; }
      { app_id = "org.kde.dolphin"; }
      { app_id = "org.kde.polkit-kde-authentication-agent-1"; }
      { app_id = "org.oe-f.openboard"; }
      { app_id = "pavucontrol"; }
      { app_id = "setroubleshoot"; }
      { app_id = "simple-scan"; }
      { app_id = "tlp-ui"; }
      { app_id = "Waydroid"; }
      { app_id = "zoom"; }
      {
        class = "jetbrains-(.*)";
        title = "splash";
      }
      {
        class = "jetbrains-(.*)";
        title = "Welcome to (.*)";
      }
      {
        class = "Steam";
        title = "Steam - News(.*)";
      }
      { window_role = "bubble"; }
      { window_role = "pop-up"; }
      { window_role = "Preferences"; }
      { window_role = "task_dialog"; }
      { window_type = "dialog"; }
      { window_type = "menu"; }
    ];
  };
}
