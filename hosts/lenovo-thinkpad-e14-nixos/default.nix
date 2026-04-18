{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.mt190502
    ./disko.nix
    ./host
    ./home
  ];
  moduleopts.nixos = {
    lanzaboote.enable = true;
    # onepassword.enable = false;
    # tailscale.enable = false;
    tlp.enable = true;
  };
  system.stateVersion = "25.11";
}
