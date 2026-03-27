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

  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ ]; # auto import these pools on boot

  # allow unfree packages for nvidia
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
