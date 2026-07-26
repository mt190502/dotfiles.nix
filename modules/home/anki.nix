{ config, pkgs, ... }:

{
  programs.anki = {
    enable = true;
    language = "en_US";
    answerKeys = [
      {
        ease = 1;
        key = "left";
      }
      {
        ease = 2;
        key = "up";
      }
      {
        ease = 3;
        key = "right";
      }
      {
        ease = 4;
        key = "down";
      }
    ];
    profiles."User 1" = {
      default = true;
      sync = {
        autoSync = true;
        autoSyncMediaMinutes = 10;
        syncMedia = true;
        url = "https://anki.mtaha.dev";
        usernameFile = config.sops.secrets."anki/username".path;
        keyFile = config.sops.secrets."anki/key".path;
      };
    };
    style = "native";
    theme = "followSystem";
    addons = with pkgs; [
      ankiAddons.anki-connect
    ];
  };
}
