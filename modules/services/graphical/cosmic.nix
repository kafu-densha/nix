{
  config,
  lib,
  ...
}:

let
  cfg = config.graphical;
in
{
  config = lib.mkIf (cfg.enable && cfg.cosmic.enable) {
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;
  };
}
