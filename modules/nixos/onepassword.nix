{ pkgs, ... }:

{
  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      package =
        with pkgs;
        _1password-gui.overrideAttrs (
          {
            buildInputs ? [ ],
            postFixup ? "",
            ...
          }:
          {
            buildInputs = buildInputs ++ [
              makeWrapper
            ];
            postFixup = postFixup + ''
              wrapProgram $out/bin/1password \
                --set XDG_CURRENT_DESKTOP GNOME \
                --append-flags "--password-store=gnome"
            '';
          }
        );
      polkitPolicyOwners = [ "taha" ];
    };
  };
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      librewolf
    '';
    mode = "0755";
  };
}
