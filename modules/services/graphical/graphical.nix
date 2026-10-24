{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:

let
  cfg = config.graphical;
in
{
  options.graphical = {
    enable = lib.mkEnableOption "graphical config";
    gnome.enable = lib.mkEnableOption "gnome desktop";
    cosmic.enable = lib.mkEnableOption "cosmic desktop";
  };

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = false;
    services.xserver.enable = true;

    # fix electron on wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # enable bluetooth
    hardware.bluetooth.enable = true;

    # yubikey support
    services.pcscd.enable = true;

    # custom ssh askpass
    ssh-askpass.enable = true;

    # fix gstreamer plugins for nautilus
    environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
        (
          with pkgs.gst_all_1;
          [
            gst-plugins-good
            gst-plugins-bad
            gst-plugins-ugly
            gst-libav
          ]
        );

    # Graphical apps
    environment.systemPackages = with pkgs; [
      # Misc
      kdePackages.konsole
      mpv
      zed-editor
      kdePackages.filelight
      kdePackages.partitionmanager
      gparted
      vesktop
      obsidian
      spotify
      google-chrome
      osu-lazer
      signal-desktop
      (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        extraPolicies = {
          DisableAppUpdate = true;
          DisableTelemetry = true;
        };
      })
      jellyfin-desktop
      transmission_4-gtk
      gimp
      davinci-resolve
      prusa-slicer
      bitwarden-desktop
      graphite
      cinny-desktop
      imagemagick
      sigil
      qpwgraph
      sublime4
      (darktable.overrideAttrs (oldAttrs: {
        cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
          "-DUSE_AI=ON" # enable darktable ai denoise
        ];
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
          onnxruntime # required to be present during build
          libarchive
        ];
      }))
      prismlauncher
      wl-clipboard
      yubioath-flutter

      # libreoffice
      libreoffice
      hunspell
      hunspellDicts.en-us
    ];

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

      fontconfig = {
        enable = true;
        defaultFonts = {
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
      };

      fontDir.enable = true;
    };
  };
}
