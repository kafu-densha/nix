{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware.nix
      ./networking.nix
      ./graphical.nix
      ../../modules/default.nix
    ];

    # TODO add fields from generated configuration.nix

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
}
