{
  source = "secret.txt";
  mode = "0400";
  group = "root";
  restartUnits = [ "tailscaled-autoconnect.service" ];
}
