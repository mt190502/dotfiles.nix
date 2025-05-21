{ ... }:
{
  security = {
    polkit.enable = true;
    pam.services = {
      "gtklock".enable = true;
      "soteria".enable = true;
      "swaylock".enable = true;
      "passwd".enableGnomeKeyring = true;
    };
    soteria.enable = true;
  };
}
