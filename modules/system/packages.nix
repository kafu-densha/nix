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

  programs.mosh.enable = true;

  programs.nix-index-database.comma.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos";
  };

  programs.tmux.enable = true;

  environment.shellAliases = {
    update = "nh os switch --ask";
  };

  environment.variables.EDITOR = "vim";
}
