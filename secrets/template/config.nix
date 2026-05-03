# This is a template for secret config.nix files
# Available types:
#   "default"      - Decrypt file to target path (default)
#   "userPassword" - For users.users.<name>.hashedPasswordFile (neededForUsers = true, not in home-manager)
#   "env"          - KEY=value dotenv file, symlinked with mode 0400 for EnvironmentFile
{
  source = "secret.yml"; # Encrypted source file name in this directory (required)
  type = "default"; # "default", "userPassword" or "env"

  # Target path (one of):
  homeTarget = ".local/share/foo/bar"; # Relative to user's home directory
  # globalTarget = "/etc/foo/bar";      # Absolute path

  # Optional:
  # mode = "0600";                      # File permissions
  # group = "wheel";                     # File group
  # restartUnits = [ "my_service" ];    # Systemd units to restart on change
  # reloadUnits = [ "my_service" ];     # Systemd units to reload on change
}
