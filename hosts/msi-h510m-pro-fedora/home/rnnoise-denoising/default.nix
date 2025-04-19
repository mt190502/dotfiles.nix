{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.rnnoise-denoising;
in
{
  options.moduleopts.rnnoise-denoising = {
    enable = lib.mkEnableOption "rnnoise-denoising";
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile."pipewire/pipewire.conf.d/99-input-denoising.conf".text = ''
      context.modules = [
        {
          name = libpipewire-module-filter-chain
          args = {
            node.description = "Noise Canceling Source"
            media.name = "Noise Canceling Source"
            filter.graph = {
              nodes = [
                {
                  type = ladspa
                  name = rnnoise
                  plugin = ${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so
                  label = noise_suppressor_mono
                  control = {
                    "VAD Threshold (%)" = 90.0
                    "VAD Grace Period (ms)" = 200
                    "Retroactive VAD Grace (ms)" = 0
                  }
                }
              ]
            }
            capture.props = {
              node.name =  "capture.rnnoise_source"
              node.passive = true
              audio.rate = 48000
            }
            playback.props = {
              node.name =  "rnnoise_source"
              media.class = Audio/Source
              audio.rate = 48000
            }
          }
        }
      ]
    '';
  };
}
