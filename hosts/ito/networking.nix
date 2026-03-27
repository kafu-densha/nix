{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ];

  networking.hostName = "ito";
  networking.networkmanager.enable = true;

  # required for zfs
  networking.hostId = "e8ae694f";
}
