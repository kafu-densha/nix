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

  environment.variables.EDITOR = "vim";
}
