{ config, lib, pkgs, ... }:

{
  imports = [];

  environment.systemPackages = with pkgs; [
    # Tools
    vim
    wget
    tree
    htop
    fastfetch
    git
    dig
    bat
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  environment.variables.EDITOR = "vim";
}
