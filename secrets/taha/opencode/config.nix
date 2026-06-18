{
  source = "secret.txt";
  mode = "0400";
  group = "root";
  excludeHosts = [ "*-server" ];
  homeTarget = ".local/share/opencode/auth.json";
}
