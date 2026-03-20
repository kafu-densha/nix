{ config, lib, pkgs, ... }:

{
  imports = [];
  
  # KDE
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
}
