{
  security = {
    polkit.enable = true;
    pam.services = {
      "mate-polkit".enable = true;
      "swaylock".enable = true;
      "passwd".enableGnomeKeyring = true;
    };
  };
}
