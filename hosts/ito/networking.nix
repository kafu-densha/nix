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
}
