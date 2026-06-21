{
  inputs,
  ...
}:

{
  boot.initrd = {
    network = {
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = (import "${inputs.self}/users/keys.nix").all;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
  };
}
