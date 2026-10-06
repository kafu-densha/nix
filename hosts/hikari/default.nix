{
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
  ];

  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = ./firmware;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "hikari";

  networking = {
    networkmanager.wifi.backend = "iwd";
    wireless = {
      enable = lib.mkForce false;
      iwd.enable = true;
    };
  };

  nixpkgs.config.allowUnsupportedSystem = true;

  stats.enable = false;

  graphical.enable = true;

  system.stateVersion = "26.11";
}
