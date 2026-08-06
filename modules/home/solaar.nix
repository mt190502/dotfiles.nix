{ lib, pkgs, ... }:

{
  xdg.configFile."solaar/rules.yaml".text = ''
    %YAML 1.3
    ---
    - Rule:
      - Key: [Emoji, pressed]
      - Execute: [${lib.getExe' pkgs.wireplumber "wpctl"}, set-mute, '@DEFAULT_AUDIO_SOURCE@', '0']
    - Rule:
      - KeyIsDown: Dictation
      - Execute: [${lib.getExe' pkgs.wireplumber "wpctl"}, set-mute, '@DEFAULT_AUDIO_SOURCE@', '0']
    - Rule:
      - Key: [Dictation, released]
      - Execute: [${lib.getExe' pkgs.wireplumber "wpctl"}, set-mute, '@DEFAULT_AUDIO_SOURCE@', '1']
    - Rule:
      - Key: [MultiPlatform Search, pressed]
      - KeyPress:
        - XF86_AudioNext
        - click
    - Rule:
      - Key: [Mute Microphone, pressed]
      - KeyPress:
        - XF86_AudioPrev
        - click
    - Rule:
      - Key: [Screen Capture, pressed]
      - KeyPress:
        - Print
        - click
    - Rule:
      - Key: [Play/Pause mini, pressed]
      - KeyPress:
        - XF86_AudioPlay
        - click
    - Rule:
      - Key: [Host Switch Channel 2, pressed]
      - Set: [E0434BF3, change-host, 1]
    ...

  '';
}
