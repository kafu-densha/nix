{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./networking.nix
    ./graphical.nix
    ./disks.nix
    ./nvidia.nix
    ../../modules/default.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # allow unfree packages for nvidia
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
