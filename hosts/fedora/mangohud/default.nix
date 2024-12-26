{ config, lib, ... }:

{
  options.pkgconfig.mangohud = {
    enable = lib.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable mangohud configuration.";
    };
  };
  config.programs.mangohud = {
    enable = config.pkgconfig.mangohud.enable;

    settings = {
      cpu_load_change = true;
      cpu_mhz = true;
      cpu_power = true;
      cpu_stats = true;
      cpu_temp = true;
      font_size = 17;
      fps = true;
      gpu_core_clock = true;
      gpu_mem_clock = true;
      gpu_name = true;
      gpu_power = true;
      gpu_stats = true;
      gpu_temp = true;
      position = "top-left";
      ram = true;
      resolution = true;
      swap = true;
      time = true;
      vkbasalt = true;
      vram = true;
    };
  };
}
