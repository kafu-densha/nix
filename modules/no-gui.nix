{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.no-gui;
in
{
  options.no-gui = {
    enable = lib.mkEnableOption "packages for just no-gui machines";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wezterm.headless # for multiplexing
    ];
  };
}
