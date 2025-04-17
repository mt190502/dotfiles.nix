{
  pkgs,
}:

pkgs.stdenv.mkDerivation {
  pname = "ubuntu-fonts-google";
  version = "1.0.0";

  nativeBuildInputs = [ pkgs.nerd-font-patcher ];

  srcs = with pkgs; [
    (fetchurl {
      url = "https://github.com/google/fonts/raw/refs/heads/main/ufl/ubuntu/Ubuntu-Bold.ttf";
      sha256 = "sha256-Z5tcHgnKsxVruO9SlzX5OCvzHKesc3OCq5WSl/jYKtQ=";
    })
    (fetchurl {
      url = "https://github.com/google/fonts/raw/refs/heads/main/ufl/ubuntu/Ubuntu-BoldItalic.ttf";
      sha256 = "sha256-h113bn8zxQsdG1lHkdoOuphlZI8jLwi8ugC7qd+gHZY=";
    })
    (fetchurl {
      url = "https://github.com/google/fonts/raw/refs/heads/main/ufl/ubuntu/Ubuntu-Italic.ttf";
      sha256 = "sha256-SrhX5y94GolnpuSprIhY+9azqfl4LbNJ1LYreO0Chgs=";
    })
    (fetchurl {
      url = "https://github.com/google/fonts/raw/refs/heads/main/ufl/ubuntu/Ubuntu-Light.ttf";
      sha256 = "sha256-pdPvifIZ6Q4fImFq3yvUqGyN3Tev9YzSI0gsROOpLu8=";
    })
    (fetchurl {
      url = "https://github.com/google/fonts/raw/refs/heads/main/ufl/ubuntu/Ubuntu-LightItalic.ttf";
      sha256 = "sha256-j8UNYji+IHb2AleNhGyBpoDzwa1Yw3LMJytN7m5o/5A=";
    })
    (fetchurl {
      url = "https://github.com/google/fonts/raw/refs/heads/main/ufl/ubuntu/Ubuntu-Medium.ttf";
      sha256 = "sha256-PNlSuLUlgeSKj6lbMciCnCuqQbY1BCppWH1X+YCSlh4=";
    })
    (fetchurl {
      url = "https://github.com/google/fonts/raw/refs/heads/main/ufl/ubuntu/Ubuntu-MediumItalic.ttf";
      sha256 = "sha256-VPZTh7Ri/vm0+0X06ENE1anPpmDigRiejV4N3PzPXow=";
    })
    (fetchurl {
      url = "https://github.com/google/fonts/raw/refs/heads/main/ufl/ubuntu/Ubuntu-Regular.ttf";
      sha256 = "sha256-MSjfhqMYBWGENtCuVlG6QoXQyd4KOQV9Al9k7jO862Q=";
    })
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/{ubuntu-fonts-google,ubuntu-fonts-google-nerd}
    for src in $srcs; do
      install -Dm644 $src $out/share/fonts/truetype/ubuntu-fonts-google/
      nerd-font-patcher --complete --outputdir $out/share/fonts/truetype/ubuntu-fonts-google-nerd/ $src
    done
  '';

  meta = {
    description = "Ubuntu font family with Nerd Variants";
    homepage = "https://github.com/google/fonts/tree/main/ufl/ubuntu";
    license = "Ubuntu Font License v1.0";
  };
}
