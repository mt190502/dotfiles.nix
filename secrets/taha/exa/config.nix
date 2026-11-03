{
  source = "secret.txt";
  mode = "0400";
  group = "root";
  excludeHosts = [ "*-server" ];
}
