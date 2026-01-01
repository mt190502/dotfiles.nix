{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.nixos.onepassword;
in
{
  options.moduleopts.nixos.onepassword = {
    package = lib.mkOption {
      type = lib.types.package;
      default =
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
      description = "1Password GUI package";
    };
  };
  config = lib.mkIf cfg.enable {
    programs._1password-gui = {
      inherit (cfg) package;
      enable = true;
      polkitPolicyOwners = [ "taha" ];
    };
    environment.etc."1password/custom_allowed_browsers" = {
      text = ''
        librewolf
      '';
      mode = "0755";
    };
  };
}
