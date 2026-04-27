{
  lib,
  pkgs,
  ...
}:

{
  programs.fish = {
    functions = {
      dnfnodep = ''
        for i in $argv
          sudo rpm -Uvh --nodeps $(dnf repoquery --location "$i" | head -n 1)
        end
      '';
      scrcpy-camera = "${lib.getExe pkgs.scrcpy} --camera-size=2560x1440 --video-codec=h265 --video-encoder=OMX.qcom.video.encoder.hevc --video-source=camera --no-audio --camera-id=1 --v4l2-sink=/dev/video0 --no-video-playback $argv";
    };
    shellAliases = {
      sysdup = lib.mkForce "sudo dnf --refresh upgrade && nix-channel --update && flatpak update && hm msi-h510m-pro-fedora-personal --update-flake";
      sysclean = lib.mkForce "flatpak remove --unused && nix-collect-garbage -d && sudo dnf remove $(dnf rq --installed --latest-limit=-1 -q)";
    };
  };
}
