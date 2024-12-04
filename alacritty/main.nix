{ ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      #~ Font
      font.size = 9;
      font.normal = {
        family = "MesloLGS NF";
        style = "Bold";
      };
      font.bold = {
        family = "Hack";
        style = "Bold";
      };
      font.italic = {
        family = "Hack";
        style = "Italic";
      };
      font.bold_italic = {
        family = "Hack";
        style = "Bold Italic";
      };

      #~ Settings
      terminal.shell.program = "tmux";
      window.dynamic_title = true;

    };
  };

  #~ Colors
  imports = [
    # ./themes/afterglow.nix
    # ./themes/alabaster.nix
    # ./themes/alabaster_dark.nix
    # ./themes/alacritty.nix
    # ./themes/argonaut.nix
    # ./themes/ashes_dark.nix
    # ./themes/ashes_light.nix
    # ./themes/atom_one_light.nix
    # ./themes/aura.nix
    # ./themes/ayu_dark.nix
    # ./themes/ayu_light.nix
    # ./themes/baitong.nix
    # ./themes/base16_default_dark.nix
    # ./themes/blood_moon.nix
    # ./themes/bluish.nix
    # ./themes/breeze.nix
    # ./themes/campbell.nix
    # ./themes/carbonfox.nix
    # ./themes/catppuccin.nix
    # ./themes/catppuccin_frappe.nix
    # ./themes/catppuccin_latte.nix
    # ./themes/catppuccin_macchiato.nix
    # ./themes/catppuccin_mocha.nix
    # ./themes/challenger_deep.nix
    # ./themes/citylights.nix
    # ./themes/Cobalt2.nix
    # ./themes/cyber_punk_neon.nix
    # ./themes/darcula.nix
    # ./themes/dark_pastels.nix
    # ./themes/deep_space.nix
    # ./themes/default.nix
    # ./themes/doom_one.nix
    # ./themes/dracula.nix
    # ./themes/everforest_dark.nix
    # ./themes/everforest_light.nix
    # ./themes/falcon.nix
    # ./themes/flat_remix.nix
    # ./themes/flexoki.nix
    # ./themes/github_dark.nix
    # ./themes/github_dark_colorblind.nix
    # ./themes/github_dark_default.nix
    # ./themes/github_dark_dimmed.nix
    # ./themes/github_dark_high_contrast.nix
    # ./themes/github_dark_tritanopia.nix
    # ./themes/github_light.nix
    # ./themes/github_light_colorblind.nix
    # ./themes/github_light_default.nix
    # ./themes/github_light_high_contrast.nix
    # ./themes/github_light_tritanopia.nix
    # ./themes/gnome_terminal.nix
    # ./themes/google.nix
    # ./themes/gotham.nix
    # ./themes/gruvbox_dark.nix
    # ./themes/gruvbox_light.nix
    # ./themes/gruvbox_material.nix
    # ./themes/gruvbox_material_hard_dark.nix
    # ./themes/gruvbox_material_hard_light.nix
    # ./themes/gruvbox_material_medium_dark.nix
    # ./themes/gruvbox_material_medium_light.nix
    # ./themes/hardhacker.nix
    # ./themes/high_contrast.nix
    # ./themes/horizon-dark.nix
    # ./themes/hyper.nix
    # ./themes/inferno.nix
    # ./themes/iris.nix
    # ./themes/iterm.nix
    # ./themes/kanagawa_dragon.nix
    # ./themes/kanagawa_wave.nix
    # ./themes/konsole_linux.nix
    # ./themes/low_contrast.nix
    # ./themes/Mariana.nix
    # ./themes/marine_dark.nix
    # ./themes/material_theme.nix
    # ./themes/material_theme_mod.nix
    # ./themes/meliora.nix
    # ./themes/midnight-haze.nix
    # ./themes/monokai_charcoal.nix
    # ./themes/monokai_pro.nix
    # ./themes/moonlight_ii_vscode.nix
    # ./themes/msx.nix
    # ./themes/night_owlish_light.nix
    # ./themes/nightfox.nix
    # ./themes/noctis-lux.nix
    # ./themes/nord.nix
    # ./themes/nord_light.nix
    # ./themes/nordic.nix
    # ./themes/oceanic_next.nix
    # ./themes/omni.nix
    # ./themes/one_dark.nix
    # ./themes/palenight.nix
    # ./themes/papercolor_dark.nix
    # ./themes/papercolor_light.nix
    # ./themes/papertheme.nix
    # ./themes/pastel_dark.nix
    # ./themes/pencil_dark.nix
    # ./themes/pencil_light.nix
    # ./themes/rainbow.nix
    # ./themes/remedy_dark.nix
    # ./themes/rose-pine-dawn.nix
    # ./themes/rose-pine-moon.nix
    # ./themes/rose-pine.nix
    # ./themes/seashells.nix
    # ./themes/smoooooth.nix
    # ./themes/snazzy.nix
    # ./themes/solarized_dark.nix
    # ./themes/solarized_light.nix
    # ./themes/solarized_osaka.nix
    # ./themes/taerminal.nix
    # ./themes/tango_dark.nix
    # ./themes/tender.nix
    # ./themes/terminal_app.nix
    # ./themes/thelovelace.nix
    # ./themes/tokyo-night-storm.nix
    # ./themes/tokyo-night.nix
    # ./themes/tomorrow_night.nix
    # ./themes/tomorrow_night_bright.nix
    # ./themes/ubuntu.nix
    ./themes/vibrant-ink.nix
    # ./themes/wombat.nix
    # ./themes/xterm.nix
    # ./themes/zenburn.nix
  ];
}
