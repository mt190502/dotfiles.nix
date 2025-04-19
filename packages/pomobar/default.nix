{
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "pomobar";
  version = "main";
  src = pkgs.fetchFromGitHub {
    owner = "mt190502";
    repo = pname;
    rev = "8888b17";
    sha256 = "sha256-efsYJx4UwkE0rkhScxgidlD+rMh+PgIb07UHj+Haapo=";
  };

  nativeBuildInputs = with pkgs; [
    gcc
    gnumake
  ];

  installPhase = ''
    mkdir -p $out/bin
    make
    cp pomobar-server pomobar-client $out/bin/
    chmod +x $out/bin/pomobar-server
    chmod +x $out/bin/pomobar-client
  '';

  meta = with pkgs.lib; {
    description = "A waybar compatible pomodoro timer (W.I.P.)";
    homepage = "https://github.com/mt190502/pomobar";
    license = licenses.gpl3;
  };
}
