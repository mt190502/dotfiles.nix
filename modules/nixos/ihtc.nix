{ inputs, ... }:

{
  imports = [ inputs.ihtc.nixosModules.default ];
  services.ihtc = {
    enable = true;
    verbose = true;
    patterns = [
      "discord"
    ];
  };
}