{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fish
    openvpn
  ];
  homebrew = {
    brews = [
      "ksops"
      "saml2aws"
      "strongswan"
      "turbot/tap/steampipe"
    ];
    casks = [
      "clickup"
      "firefox"
      "microsoft-teams"
      "slack"
      "windows-app"
    ];
    taps = [ ];
  };
}
