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
    services.system76-scheduler.enable = true;

    #  FIXME: disabled temporarily due to fcitx breaking dropdown menus
    #         see https://github.com/pop-os/cosmic-comp/issues/2778
    # i18n.inputMethod = {
    #   enable = true;
    #   type = "fcitx5";
    #   fcitx5 = {
    #     waylandFrontend = true;
    #     addons = with pkgs; [
    #       fcitx5-mozc
    #       fcitx5-gtk
    #     ];
    #     settings.inputMethod = {
    #       GroupOrder."0" = "Default";
    #       "Groups/0" = {
    #         Name = "Default";
    #         "Default Layout" = "us";
    #         DefaultIM = "mozc";
    #       };
    #       "Groups/0/Items/0".Name = "keyboard-us";
    #       "Groups/0/Items/1".Name = "mozc";
    #     };
    #     ignoreUserConfig = true;
    #   };
    # };
  };
}
