{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fish
  ];
  services.k3s.nodeName = "srv-dev.mtaha.dev";
}
