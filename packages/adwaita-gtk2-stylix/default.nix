{
  lib,
  runCommand,
  fetchurl,
  gnome-themes-extra,
  inkscape,
  base16,
  themeName ? "adwaita-gtk2-stylix",
  ...
}:

let
  hexDigits = lib.stringToCharacters "0123456789abcdef";
  hexValues = builtins.listToAttrs (lib.imap0 (value: name: { inherit name value; }) hexDigits);
  mix =
    a: b: ratio:
    let
      byte =
        color: offset:
        hexValues.${lib.toLower (builtins.substring offset 1 color)} * 16
        + hexValues.${lib.toLower (builtins.substring (offset + 1) 1 color)};
    in
    lib.concatMapStrings
      (
        offset:
        let
          value = builtins.floor (byte a offset * (1.0 - ratio) + byte b offset * ratio + 0.5);
        in
        builtins.elemAt hexDigits (value / 16) + builtins.elemAt hexDigits (lib.mod value 16)
      )
      [
        0
        2
        4
      ];

  bg = lib.removePrefix "#" base16.base00;
  dim = lib.removePrefix "#" base16.base04;
  fg = lib.removePrefix "#" base16.base05;
  accent = lib.removePrefix "#" base16.base0D;
  surface = mix bg fg 0.10;

  assetsSvg = fetchurl {
    url = "https://gitlab.gnome.org/GNOME/gnome-themes-extra/-/raw/3.28/themes/Adwaita-dark/gtk-2.0/assets.svg";
    hash = "sha256-/ba/wm2x9PxmRP4j/j8aXO1wt+ri9SZdmqc5hwZVsv4=";
  };
  assetsTxt = fetchurl {
    url = "https://gitlab.gnome.org/GNOME/gnome-themes-extra/-/raw/3.28/themes/Adwaita-dark/gtk-2.0/assets.txt";
    hash = "sha256-WbUh32Bmmjd2hN2tp3PLQ2gJbTsZrEUn+iWXQ5K1PTY=";
  };
in
runCommand themeName
  {
    nativeBuildInputs = [ inkscape ];
    meta = {
      description = "Adwaita GTK2 theme recolored to a base16 palette";
      license = lib.licenses.gpl2Plus;
      maintainers = [ ];
    };
  }
  ''
    export HOME=$TMPDIR
    mkdir -p $out/share/themes/${themeName}
    cp -r "${gnome-themes-extra}/share/themes/Adwaita-dark/gtk-2.0" $out/share/themes/${themeName}/
    chmod -R u+w $out/share/themes/${themeName}
    theme=$out/share/themes/${themeName}/gtk-2.0

    cp ${assetsSvg} $TMPDIR/assets.svg
    chmod +w $TMPDIR/assets.svg
    sed -E -i \
      -e 's/stroke:#1b1f20\b/stroke:#${mix bg fg 0.15}/gI' \
      -e '/id="border"/,/\/>/s/fill:#1b1f20\b/fill:#${mix bg fg 0.15}/gI' \
      -e 's/fill:#000000;fill-opacity:0.1;stroke:none;stroke-width:0.30000001/fill:#${fg};fill-opacity:0.15;stroke:none;stroke-width:0.30000001/g' \
      -e 's/#(1b1f20|232729|25292b|272c2e|2b3032|2e3436|0b0c0c|292929|1c1f1f|2c3133|353c3e)\b/#${bg}/gI' \
      -e 's/#(2a2e30|2d3234)\b/#${surface}/gI' \
      -e 's/#33393b\b/#${mix bg fg 0.06}/gI' \
      -e 's/#535859\b/#${mix bg fg 0.18}/gI' \
      -e 's/#(bebebe|919494|a3a6a5|c9cac9|bcbdbc|898b8b|9d9d99|cccccc|f1f1f1|fcfcfc|d3d3d1)\b/#${dim}/gI' \
      -e 's/#(eeeeec|ffffff)\b/#${fg}/gI' \
      -e 's/#(215d9c|2a76c6)\b/#${accent}/gI' \
      -e 's/#0f2b48\b/#${mix accent bg 0.30}/gI' \
      $TMPDIR/assets.svg

    while read -r id; do
      [ -n "$id" ] || continue
      inkscape --export-id="$id" --export-id-only --export-background-opacity=0 \
        --export-filename="$theme/assets/$id.png" $TMPDIR/assets.svg >/dev/null
    done < ${assetsTxt}

    for button in \
      'button:${surface}' \
      'button-hover:${mix bg fg 0.15}' \
      'button-active:${mix bg fg 0.20}' \
      'button-insensitive:${mix bg fg 0.06}'; do
      cat > $TMPDIR/button.svg <<SVG
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="34">
      <rect width="24" height="34" rx="9" fill="#''${button#*:}"/>
    </svg>
    SVG
      inkscape --export-filename="$theme/assets/''${button%%:*}.png" \
        $TMPDIR/button.svg >/dev/null
    done
    sed -i '/^style "button" {/,/^}/s/border   = {4, 4, 4, 4}/border   = {9, 9, 9, 9}/' "$theme/main.rc"
    sed -i 's/"#000000"/"#${mix bg fg 0.50}"/g' "$theme/hacks-dark.rc"

    cat > $theme/gtkrc <<'GTKRC'
    gtk-color-scheme = "text_color:#${fg}\nbase_color:#${bg}"
    gtk-color-scheme = "fg_color:#${fg}\nbg_color:#${bg}"
    gtk-color-scheme = "selected_fg_color:#${fg}\nselected_bg_color:#${accent}"
    gtk-color-scheme = "insensitive_fg_color:#${dim}\ninsensitive_bg_color:#${surface}"
    gtk-color-scheme = "menu_color:#${bg}"
    gtk-color-scheme = "link_color:#${accent}\nvisited_link_color:#${accent}"
    gtk-color-scheme = "column_header_color:#${dim}\nhover_column_header_color:#${fg}"
    gtk-color-scheme = "window_color:#${bg}"
    gtk-color-scheme = "tooltip_fg_color:#${fg}\ntooltip_bg_color:#${bg}"

    gtk-auto-mnemonics              = 1
    gtk-primary-button-warps-slider = 1
    gtk-button-images               = 0
    gtk-menu-images                 = 0

    include "main.rc"
    include "apps.rc"
    include "hacks.rc"
    include "hacks-dark.rc"
    GTKRC
  ''
