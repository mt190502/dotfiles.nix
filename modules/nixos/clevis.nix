{ config, pkgs, ... }:

let
  disks = config.disko.devices.disk or { };
  clevisUnlock = name: partLabel: ''
    export PATH=$PATH:${pkgs.curl}/bin:${pkgs.gnused}/bin:${pkgs.util-linux}/bin:${pkgs.clevis}/bin
    clevis luks unlock -d $(blkid -t PARTLABEL="${partLabel}" -o device) -n ${name}
  '';
  luksPartLabels =
    let
      diskNames = builtins.attrNames disks;
      luksEntries = builtins.concatLists (
        builtins.map (
          diskName:
          let
            disk = disks.${diskName};
            partitions = disk.content.partitions or { };
            partNames = builtins.attrNames partitions;
          in
          builtins.filter (x: x != null) (
            builtins.map (
              partName:
              let
                part = partitions.${partName};
                content = part.content or { };
              in
              if (content.type or null) == "luks" then
                {
                  inherit (content) name;
                  value = "disk-${diskName}-${partName}";
                }
              else
                null
            ) partNames
          )
        ) diskNames
      );
    in
    builtins.listToAttrs luksEntries;
in
{
  boot.initrd = {
    clevis = {
      enable = true;
      useTang = true;
    };
    luks.devices = builtins.mapAttrs (name: partLabel: {
      preOpenCommands = clevisUnlock name partLabel;
    }) luksPartLabels;
    network = {
      enable = true;
      udhcpc.enable = true;
    };
  };
}
