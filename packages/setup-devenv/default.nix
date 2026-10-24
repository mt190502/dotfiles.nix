{
  coreutils,
  findutils,
  git,
  gnused,
  writeShellApplication,
  ...
}:

writeShellApplication {
  name = "setup-devenv";

  runtimeInputs = [
    coreutils
    findutils
    git
    gnused
  ];

  text = ''
    TEMPLATES=${./templates}
    ${builtins.readFile ./setup-devenv.sh}
  '';
}
