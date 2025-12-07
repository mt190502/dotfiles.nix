{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.mt190502
    ./host
    ./home
  ];

  moduleopts.darwin = { };
  system = {
    primaryUser = "taha";
    stateVersion = 6;
  };
}
