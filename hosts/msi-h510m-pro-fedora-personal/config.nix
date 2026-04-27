{
  stateVersion = "25.11";
  platform = "home";
  arch = "x86_64-linux";
  user = "taha";
  modules = [
    "delta"
    "direnv"
    "fastfetch"
    "fish"
    "flatpak"
    "fontconfig"
    "foot"
    "git"
    "gtk"
    "kde-apps-wm-fix"
    "kdeconnect"
    "mangohud"
    "mpdris2-rs"
    "mpv"
    "qt-apps-wm-fix"
    "rmpc"
    "rnnoise"
    "scripts"
    "swappy"
    "syncthing"
    "vicinae"
    "yazi"
    "ytdlp"
    "zed"
  ];
  profiles = [
    "ai"
    "cloud"
    "development"
    "mediaplayer"
    "neovim"
    "sway"
    "tmux"
  ];
  packages = [ ];
  extraConfig = { ... }: { };
}
