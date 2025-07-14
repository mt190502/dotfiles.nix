{
  security = {
    polkit.enable = true;
    pam.services = {
      "gtklock".enable = true;
      "mate-polkit".enable = true;
      "swaylock".enable = true;
      "passwd".enableGnomeKeyring = true;
    };
  };
}
