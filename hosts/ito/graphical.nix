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

  # Graphical apps
  environment.systemPackages = with pkgs; [
    mpv
    zed-editor
    kdePackages.filelight
    kdePackages.partitionmanager
    gparted
    vesktop
    obsidian
    spotify
    google-chrome
    osu-lazer-bin

    # Gaming
    lutris
    protonplus
    prismlauncher
  ];

  # Gaming
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [
      kdePackages.breeze # fix cursor theme
    ];
  };

  # OBS
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Defaults
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols

      # Japanese
      ipaexfont

      # Terminal font
      meslo-lgs-nf
    ];

    fontconfig.defaultFonts = {
      monospace = [
        "Fira Code"
        "IPAexGothic"
      ];
      sansSerif = [
        "Noto Sans"
        "IPAexGothic"
      ];
      serif = [
        "Noto Serif"
        "IPAexMincho"
      ];
    };

    fontDir.enable = true;
  };
}
