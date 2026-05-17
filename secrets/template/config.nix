# This is a template for secret config.nix files
# Available types:
#   "default"      - Decrypt file to target path (default)
#   "userPassword" - For users.users.<name>.hashedPasswordFile (neededForUsers = true, not in home-manager)
#   "env"          - KEY=value dotenv file, symlinked with mode 0400 for EnvironmentFile
#
# Secret placement:
#   User-specific:  secrets/<username>/<secret>/config.nix   (owner = username)
#   Global:         secrets/global/<secret>/config.nix       (no owner, system-level)
#
# For YAML secrets with individual keys:
#   - Set format = "yaml" and list the keys to extract.
#   - Each key becomes a separate secret: <secret>/<key>
#   - Access via config.sops.secrets."<entry>/<secret>/<key>".path
{
  source = "secret.yml"; # Encrypted source file name in this directory (required)
  format = "binary"; # "binary" (default) or "yaml"
  # keys = [ "username" "password" ]; # Required when format = "yaml": extracts each key as a separate secret
  type = "default"; # "default", "userPassword" or "env" (ignored for global secrets)

  # Target path (one of):
  homeTarget = ".local/share/foo/bar"; # Relative to user's home directory (user-specific only)
  # globalTarget = "/etc/foo/bar"; # Absolute path (required for global secrets, optional for user)

  # Optional:
  # mode = "0600"; # File permissions
  # Host filtering (glob patterns, matched against flakeName):
  # hosts = [ "msi-h510m-pro-nixos-personal" ]; # Only deploy to these hosts (default: all)
  # excludeHosts = [ "*-server" ]; # Exclude from these hosts
  # group = "wheel"; # File group
  # restartUnits = [ "my_service" ]; # Systemd units to restart on change
  # reloadUnits = [ "my_service" ]; # Systemd units to reload on change
}
