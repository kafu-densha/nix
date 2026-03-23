{ pkgs, lib, config, ... }:

{
  imports = [];

  home.packages = with pkgs; [
    bat
    lsd
    ripgrep
  ];

  home.shellAliases = {
    ls = "lsd";
    ll = "ls -l";
    la = "ls -la";
  };

  # Git config
  programs.git = {
    enable = true;
    settings = {
     	user = {
     	  name = "Blake Haug";
     	  email = "elena@elenahaug.com";
     	};
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedsignersfile = "${config.home.homeDirectory}/.ssh/allowed_signers";
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      init.defaultbranch = "main";
    };
  };

  programs.zsh.enable = true;
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.mkMerge [
      (lib.importTOML ./starship-nerd-font-symbols.toml)
      (lib.importTOML ./starship.toml)
    ];
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.11";
}
