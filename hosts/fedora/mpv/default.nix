{ config, lib, ... }:

{
  options.pkgconfig.mpv = {
    enable = lib.mkEnableOption "Enable mpv configuration.";
  };
  config.programs.mpv = {
    enable = config.pkgconfig.mpv.enable;

    bindings = {
      "Shift+s" = "cycle secondary-sid";
      "Shift+z" = "secondary-sub-delay -0.1";
      "Shift+x" = "secondary-sub-delay +0.1";
    };

    config = {
      #################################################
      #
      ## Video settings
      #
      #################################################
      #~ specify high quality video rendering preset (for --vo=<gpu|gpu-next> only)
      profile = "high-quality";

      #~ enable hardware decoding if available
      hwdec = "vaapi";

      #~ video output (gpu: integrated, gpu-next: dedicated)
      vo = "gpu";

      #~ caching
      cache = "yes";
      cache-on-disk = "yes";
      demuxer-max-bytes = "1024M";
      demuxer-cache-dir = "~/.cache/";
      demuxer-max-back-bytes = "512M";

      #################################################
      #
      ## Audio settings
      #
      #################################################
      #~ audio output
      ao = "pipewire";

      #~ audio language
      alang = "eng,en,enUS,tr,trTR";

      #################################################
      #
      ## Text Settings
      #
      #################################################
      #~ subtitle language
      slang = "eng,en,enUS,tr,trTR";

      #~ automatically choose subtitle track based on language match
      #sub-auto = "fuzzy";
      sub-auto = "all";

      #~ adjust subtitle timing
      sub-fix-timing = "yes";

      #~ disable compatibility with VSFilter-style blur in ASS subtitles
      #sub-ass-use-video-data = "no";

      #~ apply Gaussian blur to subtitles
      sub-gauss = "1.0";

      #~ display subtitles in grayscale
      sub-gray = "yes";

      #~ subtitle paths
      sub-file-paths = "~/NextCloud/Documents/srt/";

      #################################################
      #
      ## Interface settings
      #
      #################################################
      #~ force starting with centered window
      geometry = "70%:70%";

      #~ fullscreen mode
      #fs = "yes";

      #~ do not close the window on exit
      #keep-open = "yes";

      #~ disable the On Screen Controller (OSC)
      #osc = "no";

      #~ disable OSD progress bar
      osd-bar = "no";
      ontop = "yes";

      #################################################
      #
      ## Other settings
      #
      #################################################
      #~ format for screenshots
      screenshot-format = "png";

      #~ save position on quit
      save-position-on-quit = "yes";
    };
  };
}
