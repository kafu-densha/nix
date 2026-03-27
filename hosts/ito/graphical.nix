{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ];

  # KDE
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  services.xserver.enable = true;

  services.flatpak = {
    enable = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
    packages = [
      "app.zen_browser.zen"
    ];
  };

  environment.systemPackages = with pkgs; [
    mpv
    zed-editor
  ];
}
