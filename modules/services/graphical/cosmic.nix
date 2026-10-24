{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.graphical;
in
{
  config = lib.mkIf (cfg.enable && cfg.cosmic.enable) {
    services.displayManager.cosmic-greeter = {
      enable = true;
      package = pkgs.cosmic-greeter.overrideAttrs (prev: {
        postPatch = (prev.postPatch or "") + ''
          cp ${inputs.wallpaper} res/background.jpg
        '';
      });
    };
    services.desktopManager.cosmic.enable = true;
    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
  };
}
