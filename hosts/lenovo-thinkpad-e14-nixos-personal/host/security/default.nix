{
  security = {
    polkit.enable = true;
    pam.services = {
      "login".fprintAuth = false;
      "mate-polkit".enable = true;
      "swaylock".enable = true;
      "passwd".enableGnomeKeyring = true;
    };
  };
}
