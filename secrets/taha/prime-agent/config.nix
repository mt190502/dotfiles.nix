{
  source = "secret.txt";
  mode = "0400";
  group = "root";
  excludeHosts = [ "*-server" ];
  homeTarget = ".local/state/codex-auth/prime-agent.json";
}
