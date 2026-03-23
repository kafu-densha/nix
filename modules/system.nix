{ config, lib, pkgs, inputs, pubkeys, ... }:

{
  imports = [];

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  
  # Setup shell
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;

  users.users.elenah = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = pubkeys;
  };
}
