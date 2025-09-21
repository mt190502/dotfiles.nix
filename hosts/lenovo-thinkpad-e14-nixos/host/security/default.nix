{
  security = {
    polkit.enable = true;
    pam.services = {
      "gtklock".enable = true;
      "login".fprintAuth = false;
      "mate-polkit".enable = true;
      "swaylock".enable = true;
      "passwd".enableGnomeKeyring = true;
    };
  };
}
