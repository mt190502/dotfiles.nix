{ pkgs, ... }:

{
  programs.zed-editor = {
    extensions = [ "csharp" ];
    extraPackages = with pkgs; [
      omnisharp-roslyn
      dotnet-sdk_9
    ];
    userSettings = {
      auto_install_extensions.csharp = true;
      languages.CSharp = {
        language_servers = [ "omnisharp" ];
      };
    };
  };
}
