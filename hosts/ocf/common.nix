{
  config,
  lib,
  ...
}:

{
  home.username = "elenah";
  home.homeDirectory = "/home/b/bl/elenah";

  services.ssh-agent.enable = true;

  programs.ssh.settings."*".identityFile = lib.mkForce "~/.ssh/id_ed25519_sk.pub";

  programs.git.settings.user.signingkey =
    lib.mkForce "${config.home.homeDirectory}/.ssh/id_ed25519_sk.pub";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
