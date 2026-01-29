{ config, lib, pkgs, inputs, ... }:

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

    inputs.neovim-flake.packages.${pkgs.system}.default
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos";
  };

  environment.shellAliases = {
    update = "nh os switch --ask";
  };

  environment.variables.EDITOR = "vim";
}
