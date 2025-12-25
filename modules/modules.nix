{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./system/system.nix
      ./web/web.nix
    ];
}
