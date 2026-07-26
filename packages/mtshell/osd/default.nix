{
  lib,
  pkgs,
  quickshell ? pkgs.quickshell,
  osdConfig ? { },
  ...
}:

let
  cfg = osdConfig;
  osd-bg = cfg.bg or "#1e1e2e";
  osd-text = cfg.text or "#cdd6f4";
  osd-accent = cfg.accent or "#89b4fa";
  osd-border = cfg.border or osd-accent;
  osd-font-name = cfg.fontName or "Sans";
  volume-icons =
    cfg.volumeIcons or [
      " "
      " "
      " "
      " "
      " "
    ];
  volume-muted-icon = cfg.volumeMutedIcon or "󰝟";
  brightness-icons =
    cfg.brightnessIcons or [
      "󰃞"
      "󰃝"
      "󰃟"
      "󰃠"
      "󰃚"
    ];
  keyboard-icon = cfg.keyboardIcon or "";
  osd-swaymsg = lib.getExe' pkgs.sway "swaymsg";

  subs = {
    inherit
      osd-bg
      osd-text
      osd-accent
      osd-border
      osd-font-name
      osd-swaymsg
      ;
    volume-icon-0 = builtins.elemAt volume-icons 0;
    volume-icon-1 = builtins.elemAt volume-icons 1;
    volume-icon-2 = builtins.elemAt volume-icons 2;
    volume-icon-3 = builtins.elemAt volume-icons 3;
    volume-icon-4 = builtins.elemAt volume-icons 4;
    inherit volume-muted-icon;
    brightness-icon-0 = builtins.elemAt brightness-icons 0;
    brightness-icon-1 = builtins.elemAt brightness-icons 1;
    brightness-icon-2 = builtins.elemAt brightness-icons 2;
    brightness-icon-3 = builtins.elemAt brightness-icons 3;
    brightness-icon-4 = builtins.elemAt brightness-icons 4;
    inherit keyboard-icon;
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
  qmlFiles = builtins.filter (name: lib.hasSuffix ".qml" name) (
    builtins.attrNames (builtins.readDir qmlSrc)
  );

  qmlDir = pkgs.runCommandLocal "mtshell-osd-qml" { } ''
    mkdir -p $out
    ${lib.concatMapStringsSep "\n" (
      name: "cp ${substituteQml "${qmlSrc}/${name}"} $out/${name}"
    ) qmlFiles}
  '';
in
with pkgs;
stdenv.mkDerivation {
  pname = "mtshell-osd";
  version = "0.1.0";

  src = qmlDir;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mtshell/osd
    cp -r "$src"/. $out/share/mtshell/osd/

    mkdir -p $out/bin
    cat >$out/bin/mtshell-osd <<'SCRIPT'
    #!${runtimeShell}
    exec ${lib.getExe quickshell} -p ${placeholder "out"}/share/mtshell/osd/shell.qml "$@"
    SCRIPT
    chmod +x $out/bin/mtshell-osd

    runHook postInstall
  '';

  passthru.templatesPath = "${placeholder "out"}/share/mtshell/osd";

  meta = {
    description = "MTShell OSD";
    mainProgram = "mtshell-osd";
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
}
