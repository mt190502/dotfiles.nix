{
  source = "secret.yaml";
  format = "yaml";
  keys = [
    "username"
    "key"
  ];
  excludeHosts = [ "*-server" ];
  mode = "0400";
  group = "root";
}
