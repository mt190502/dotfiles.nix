{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    fish
  ];
  services = {
    k3s = {
      package = pkgs-unstable.k3s;
      nodeName = "srv-internal.mtaha.dev";
    };
    nfs.server = {
      enable = true;
      exports = ''
        /mnt/ssd/nfs/win   192.168.1.51/32(rw,no_subtree_check,no_root_squash)
        /mnt/ssd/nfs       192.168.1.50/32(rw,no_subtree_check,anonuid=1000,anongid=1000)
      '';
    };
  };
}
