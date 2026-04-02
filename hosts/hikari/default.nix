{
  self,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ];

  users.users.elenah = {
    name = "elenah";
    home = "/Users/elenah";
  };

  programs.zsh.enable = true;

  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    # Nix related
    nh
    nil
    nixd
    devenv

    # Graphical
    aseprite

    # Misc
    mosh
  ];

  # setup nix helper
  environment.variables.NH_FLAKE = "/Users/elenah/.nixos";

  environment.variables.VISUAL = "nvim";

  # fix ssh agent
  environment.variables.SSH_SK_PROVIDER = "/usr/local/lib/sk-libfido2.dylib";

  programs.nix-index-database.comma.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
