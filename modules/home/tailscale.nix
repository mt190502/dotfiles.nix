{
  lib,
  osConfig ? null,
  ...
}:

{
  services.tailscale-systray = {
    enable = lib.mkIf (osConfig != null && osConfig.services.tailscale.enable) true;
    theme = "dark:nobg";
  };
}
