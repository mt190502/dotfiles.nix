{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.mate.mate-polkit.overrideAttrs {
      postInstall = ''
        sed -i '/OnlyShowIn/d' $out/etc/xdg/autostart/polkit-mate-authentication-agent-1.desktop
      '';
    })
  ];
}
