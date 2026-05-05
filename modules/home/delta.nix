{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      color.ui = "auto";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
