{
  config,
  pkgs,
  ...
}:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/rancher/k3s/server/manifests 0755 root root -"
    "L+ /var/lib/rancher/k3s/server/manifests/garage-namespace.yaml - - - - ${./namespace.yaml}"
    "L+ /var/lib/rancher/k3s/server/manifests/garage.yaml - - - - ${./garage.yaml}"
    "L+ /var/lib/rancher/k3s/server/manifests/garage-webui.yaml - - - - ${./webui.yaml}"
  ];
  systemd.services.garage-k8s-secrets = {
    after = [
      "k3s.service"
      "sops-nix.service"
    ];
    wants = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [
      pkgs.sops
      config.services.k3s.package
    ];
    environment.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
    script = ''
      until kubectl get nodes 2>/dev/null; do
        sleep 5
      done
      sops -d ${./configmap.yaml} | kubectl apply -f -
      sops -d ${./webui-secret.yaml} | kubectl apply -f -
    '';
  };
}
