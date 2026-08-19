{ pkgs, ... }:

with pkgs;
openboard.overrideAttrs (oldAttrs: {
  buildInputs = builtins.filter (input: input != ffmpeg) oldAttrs.buildInputs ++ [ ffmpeg_6 ];
  postPatch = (oldAttrs.postPatch or "") + ''
    substituteInPlace src/pdf/XPDFRenderer.cpp \
      --replace-fail 'title.getString()->c_str()' 'title.getString().c_str()'
  '';
})
