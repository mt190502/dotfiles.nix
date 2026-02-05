{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.darwin;
in
{
  environment.systemPackages = with pkgs; [
    fish
    openvpn
  ];
  homebrew = lib.mkIf cfg.homebrew.enable {
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
