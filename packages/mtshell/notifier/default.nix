{
  lib,
  pkgs,
  quickshell ? pkgs.quickshell,
  iconThemePackage ? pkgs.papirus-icon-theme,
  notifierConfig ? { },
  ...
}:

let
  cfg = notifierConfig;

  base = cfg.base or { };
  cc-bg = base.bg or "#1e1e2e";
  cc-text = base.text or "#cdd6f4";
  cc-active = base.active or "#89b4fa";
  cc-inactive = base.inactive or "#45475a";
  cc-subtext = base.subtext or "#a6adc8";
  cc-urgent = base.urgent or "#f38ba8";
  cc-border = base.border or "#45475a";
  cc-font-name = base.fontName or "Sans Serif";
  cc-font-size = base.fontSize or 12;

  cc = cfg.controlCenter or { };
  cc-width = cc.width or 500;
  cc-height = cc.height or 500;
  cc-margin-top = cc.marginTop or 5;
  cc-margin-bottom = cc.marginBottom or 5;
  cc-margin-left = cc.marginLeft or 0;
  cc-margin-right = cc.marginRight or 5;
  cc-positionY = cc.positionY or "center";

  mp = cfg.mpris or { };
  mpris-icon-play = mp.iconPlay or "";
  mpris-icon-pause = mp.iconPause or "";
  mpris-icon-next = mp.iconNext or "";
  mpris-icon-previous = mp.iconPrevious or "";
  mpris-icon-shuffle = mp.iconShuffle or "";
  mpris-icon-shuffle-active = mp.iconShuffleActive or "";
  mpris-icon-repeat = mp.iconRepeat or "";
  mpris-icon-repeat-active = mp.iconRepeatActive or "";
  mpris-icon-repeat-one = mp.iconRepeatOne or "";
  mpris-image-size = mp.imageDisplaySize or 100;

  cc-icon-dnd = cfg.iconDnd or "";
  cc-icon-dnd-active = cfg.iconDndActive or "";

  notif = cfg.notifications or { };
  notif-icon-size = notif.iconSize or 32;

  pop = cfg.popup or { };
  popup-width = pop.width or 350;
  popup-margin = pop.margin or 8;
  popup-icon-size = pop.iconSize or 32;
  popup-duration = pop.duration or 5;
  popup-max = pop.maxVisible or 3;
  wl-copy-bin = "${pkgs.wl-clipboard}/bin/wl-copy";

  base-icon-theme = (cfg.base or { }).iconTheme or "Papirus-Dark";

  iconThemeConf = pkgs.runCommand "mtshell-notifier-icon-theme-conf" { } ''
    mkdir -p $out/icons/default
    cat >$out/icons/default/index.theme <<THEME
    [Icon Theme]
    Inherits=${base-icon-theme}
    THEME
  '';

  cc-anchor-top = if cc-positionY == "center" || cc-positionY == "bottom" then "top" else "# top";
  cc-anchor-bottom =
    if cc-positionY == "center" || cc-positionY == "top" then "bottom" else "# bottom";

  subs = {
    inherit
      cc-bg
      cc-text
      cc-active
      cc-inactive
      cc-subtext
      cc-urgent
      cc-border
      cc-font-name
      cc-font-size
      cc-width
      cc-height
      cc-margin-top
      cc-margin-bottom
      cc-margin-left
      cc-margin-right
      cc-anchor-top
      cc-anchor-bottom
      mpris-icon-play
      mpris-icon-pause
      mpris-icon-next
      mpris-icon-previous
      mpris-icon-shuffle
      mpris-icon-shuffle-active
      mpris-icon-repeat
      mpris-icon-repeat-active
      mpris-icon-repeat-one
      mpris-image-size
      cc-icon-dnd
      cc-icon-dnd-active
      notif-icon-size
      popup-width
      popup-margin
      popup-icon-size
      popup-duration
      popup-max
      wl-copy-bin
      ;
  };

  substituteQml =
    src:
    pkgs.substitute {
      inherit src;
      substitutions = lib.flatten (
        lib.mapAttrsToList (k: v: [
          "--replace"
          "@${k}@"
          (toString v)
        ]) subs
      );
    };

  qmlSrc = ./qml;
  qmlFiles = builtins.concatMap (
    dir:
    let
      basePath = if dir == "root" then qmlSrc else "${qmlSrc}/${dir}";
      entries = builtins.readDir basePath;
    in
    lib.mapAttrsToList
      (name: _: {
        inherit name;
        src = "${basePath}/${name}";
        dest = if dir == "root" then name else "${dir}/${name}";
      })
      (
        lib.filterAttrs (
          n: t: t == "regular" && (lib.hasSuffix ".qml" n || lib.hasSuffix ".js" n || n == "qmldir")
        ) entries
      )
  ) [ "root" ];

  qmlDir = pkgs.runCommandLocal "mtshell-notifier-qml" { } ''
    ${lib.optionalString (builtins.length qmlFiles > 0) "mkdir -p $out"}
    ${lib.concatStringsSep "\n" (
      map (f: ''
        cp ${substituteQml f.src} $out/${f.dest}
      '') qmlFiles
    )}
  '';
in
with pkgs;
stdenv.mkDerivation {
  pname = "mtshell-notifier";
  version = "0.1.0";

  src = qmlDir;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mtshell/notifier
    cp -r "$src"/. $out/share/mtshell/notifier/

    mkdir -p $out/bin
    cat >$out/bin/mtshell-notifier <<'SCRIPT'
    #!${runtimeShell}
    export XDG_DATA_DIRS="${iconThemeConf}:${iconThemePackage}/share:$XDG_DATA_DIRS"
    export XDG_CURRENT_DESKTOP="KDE"
    exec ${lib.getExe quickshell} -p ${placeholder "out"}/share/mtshell/notifier/shell.qml "$@"
    SCRIPT
    chmod +x $out/bin/mtshell-notifier

    runHook postInstall
  '';

  passthru.templatesPath = "${placeholder "out"}/share/mtshell/notifier";

  meta = {
    description = "MTShell notifier";
    mainProgram = "mtshell-notifier";
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
}
