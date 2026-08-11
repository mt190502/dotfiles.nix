{ config, pkgs, ... }:

let
  #~ Addon source: an __init__.py that hooks into Anki's profile_did_open
  #~ and creates the deck + note type via the AnkiConnect HTTP API.
  mpvacious-bootstrap = pkgs.writeText "mpvacious-bootstrap-init.py" ''
    from aqt import gui_hooks
    import json
    import urllib.request

    ANKICONNECT_URL = "http://127.0.0.1:8765"

    def _anki_connect(action, **params):
        payload = json.dumps({"action": action, "version": 5, "params": params}).encode()
        req = urllib.request.Request(ANKICONNECT_URL, data=payload)
        with urllib.request.urlopen(req, timeout=5) as resp:
            return json.loads(resp.read())

    def _bootstrap():
        try:
            _anki_connect("createDeck", deck="English::00: Collection::subs2srs")
            models = _anki_connect("modelNames")
            if "English sentences" not in models.get("result", []):
                _anki_connect(
                    "createModel",
                    modelName="English sentences",
                    inOrderFields=${
                      builtins.toJSON [
                        "SentEng"
                        "SentTr"
                        "SentAudio"
                        "Image"
                      ]
                    },
                    cardTemplates=[{
                        "Name": "Recognition",
                        "Front": "{{SentEng}}",
                        "Back": "{{SentTr}}<br>{{SentAudio}}<br>{{Image}}",
                    }],
                )
        except Exception as e:
            print(f"mpvacious-bootstrap: failed: {e}")

    gui_hooks.profile_did_open.append(_bootstrap)
  '';

  bootstrapAddon = pkgs.anki-utils.buildAnkiAddon (_: {
    pname = "mpvacious-bootstrap";
    version = "1.0.0";
    src = pkgs.runCommandLocal "mpvacious-bootstrap-src" { } ''
      mkdir -p "$out"
      cp ${mpvacious-bootstrap} "$out/__init__.py"
      cp ${
        pkgs.writeText "mpvacious-bootstrap-manifest.json" (
          builtins.toJSON {
            name = "mpvacious Bootstrap";
            package = "mpvacious-bootstrap";
            version = "1.0.0";
          }
        )
      } "$out/manifest.json"
      cp ${pkgs.writeText "mpvacious-bootstrap-config.json" "{}"} "$out/config.json"
    '';
    dontBuild = true;
  });
in
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
      bootstrapAddon
    ];
  };
}
