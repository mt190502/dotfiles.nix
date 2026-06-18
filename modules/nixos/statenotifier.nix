{
  config,
  flakeName,
  pkgs,
  ...
}:

let
  send = state: message: ''
    ${pkgs.curl}/bin/curl -s -X POST -H "Content-Type: application/json" \
      -d '{"title": "[${
        if state == "up" then
          "🟢"
        else if state == "down" then
          "🔴"
        else
          "⚪️"
      }] ${flakeName}", "message": "${message}", "priority": 5}' \
      "$(cat ${config.sops.secrets."gotify".path})" || true
  '';
in
{
  systemd.services = {
    statenotifier-power = {
      description = "State Notifier for Power Events";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "sops-nix.service"
      ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = send "up" "Machine is up and running!";
      preStop = send "down" "Machine is shutting down...";
    };
    statenotifier-sleep = {
      description = "State Notifier for Sleep Events";
      before = [ "sleep.target" ];
      wantedBy = [ "sleep.target" ];
      serviceConfig.Type = "oneshot";
      script = send "down" "Machine is going to sleep...";
    };
  };
  powerManagement.resumeCommands = ''
    until ${pkgs.netcat}/bin/nc -zw3 1.1.1.1 443; do sleep 1; done
    ${send "up" "Machine is resuming from sleep..."}
  '';
}
