{ pkgs, ... }:

{
  imports = [];

  home.packages = [ ];

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

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.11";
}
