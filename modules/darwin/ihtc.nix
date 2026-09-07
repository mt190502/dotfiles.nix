{ inputs, ... }:

{
  imports = [ inputs.ihtc.darwinModules.default ];
  services.ihtc = {
    enable = true;
    verbose = true;
    patterns = [
      "discord"
    ];
  };
}
