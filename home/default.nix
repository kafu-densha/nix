{ pkgs, lib, ... }:

{
  imports = [];

  home.packages = with pkgs; [
    lsd
    ripgrep
  ];

  home.shellAliases = {
    ls = "lsd";
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
      gpg.ssh.allowedsignersfile = "/home/elenah/.ssh/allowed_signers";
      user.signingkey = "/home/elenah/.ssh/id_ed25519.pub";
      init.defaultbranch = "main";
    };
  };

  programs.bash.enable = true;
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = lib.mkMerge [
      (lib.importTOML ./starship-nerd-font-symbols.toml)
      (lib.importTOML ./starship.toml)
    ];
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.11";
}
