{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [ ];

  home.packages = with pkgs; [
    bat
    lsd
    ripgrep-all
    aria2
    btop
    croc
    diff-so-fancy
    dos2unix
    exiftool
    fastfetch
    ffmpeg
    gh
    glow
    jq
    iperf
    lazygit
    pre-commit
    qrencode
    rclone
    restic
    rhash
    speedtest-cli
    pay-respects
    wakeonlan
    yubikey-manager
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
      core.pager = "diff-so-fancy | less --tabs=4 -RF";
      interactive.diffFilter = "diff-so-fancy --patch";
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.11";
}
