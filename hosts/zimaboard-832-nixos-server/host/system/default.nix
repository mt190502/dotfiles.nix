{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    fish
  ];
  services.k3s = {
    package = pkgs-unstable.k3s;
    nodeName = "srv-internal.mtaha.dev";
  };
}
