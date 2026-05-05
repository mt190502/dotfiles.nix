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
    "kdeconnect"
    "mangohud"
    "mpdris2-rs"
    "mpv"
    "rmpc"
    "rnnoise"
    "scripts"
    "stylix"
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
