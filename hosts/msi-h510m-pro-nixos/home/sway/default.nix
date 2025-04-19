{ config, ... }:

{
  wayland.windowManager.sway = {
    config.startup = [
      {
        command = "${config.wrapped.onepassword-gui}/bin/1password --silent --password-store=gnome";
      }
    ];
  };
}
