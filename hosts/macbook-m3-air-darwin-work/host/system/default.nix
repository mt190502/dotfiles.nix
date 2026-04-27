{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fish
    openvpn
  ];
  homebrew = {
    brews = [
      "saml2aws"
      "ksops"
      "turbot/tap/steampipe"
    ];
    casks = [
      "clickup"
      "firefox"
      "microsoft-teams"
      "slack"
    ];
    taps = [ ];
  };
}
