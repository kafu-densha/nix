{
  config,
  lib,
  ...
}:

{
  imports = [ ];

  nixpkgs.config.allowUnfree = true;

  home.username = "elenah";
  home.homeDirectory = "/home/e/el/elenah";

  services.ssh-agent.enable = lib.mkForce false;

  programs.ssh.settings."*".identityFile = lib.mkForce "~/.ssh/id_ed25519_sk";

  programs.git.settings.user.signingkey =
    lib.mkForce "${config.home.homeDirectory}/.ssh/id_ed25519_sk.pub";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SKIP_OCF_ZSHRC = "1";
    PURE_GIT_PULL = "0"; # prevent pure from querying git repo status (prompts yubikey)
    # SSH_ASKPASS = "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
  };

  nix.settings.substituters = lib.mkForce [
    "https://cache.nixos.org"
    "https://cache.ocf.berkeley.edu"
  ];
  nix.settings.trusted-public-keys = lib.mkForce [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cache.ocf.berkeley.edu-1:6n9lihkjExzagz8GYR1QY/ZthT/XAKOy+ju5Jxd6wBg="
  ];
}
