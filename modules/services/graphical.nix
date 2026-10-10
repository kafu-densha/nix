{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:

let
  cfg = config.graphical;

  wallpaper = pkgs.fetchurl {
    url = "https://storage.kafu.observer/wallpapers/kafu.png";
    sha256 = "14bq4rna783jy0flmsm8g0ik64d100acr8j11rnq7s8nlnz5jbhs";
  };

  paperwm-patched = (
    pkgs.gnomeExtensions.paperwm.overrideAttrs (prevAttrs: {
      patches = (prevAttrs.patches or [ ]) ++ [
        ./paperwm-scroll-windows.patch
      ];
    })
  );
in
{
  options.graphical = {
    enable = lib.mkEnableOption "graphical config";
  };

  config = lib.mkIf cfg.enable {
    # overlay to fix copyous (see nixpkgs pr #545762)
    nixpkgs.overlays = [
      (self: super: {
        gnomeExtensions = super.gnomeExtensions // {
          copyous = super.gnomeExtensions.copyous.overrideAttrs (oldAttrs: {
            buildInputs = (builtins.filter (p: p.pname or "" != "libgda6") (oldAttrs.buildInputs or [ ])) ++ [
              self.libgda5
            ];
            preInstall = ''
              sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${self.libgda5}/lib/girepository-1.0');\nGIRepository.Repository.dup_default().prepend_search_path('${super.gsound}/lib/girepository-1.0');\n" lib/preferences/dependencies/dependencies.js
              sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${self.libgda5}/lib/girepository-1.0');\n" lib/database/entryTracker.js
              sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${super.gsound}/lib/girepository-1.0');\n" lib/common/sound.js
              sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${super.gsound}/lib/girepository-1.0');\n" lib/preferences/general/feedbackSettings.js
            '';
          });
        };
      })
    ];

    # fix electron on wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # enable bluetooth
    hardware.bluetooth.enable = true;

    # yubikey support
    services.pcscd.enable = true;

    # gnome
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.xserver.enable = true;
    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
    systemd.services.power-profiles-daemon.enable = true;
    environment.gnome.excludePackages = with pkgs; [ gnome-tour ];
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        mozc
      ];
    };
    # environment.sessionVariables.GTK_THEME = "Adwaita:dark";
    programs.dconf.profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = with pkgs.gnomeExtensions; [
              paperwm-patched.extensionUuid
              blur-my-shell.extensionUuid
              brightness-control-using-ddcutil.extensionUuid
              copyous.extensionUuid
            ];
            favorite-apps = [
              "zen.desktop"
              "dev.zed.Zed.desktop"
              "org.gnome.Nautilus.desktop"
              "org.wezfurlong.wezterm.desktop"
            ];
          };
          "org/gnome/desktop/interface" = {
            # color-scheme = "prefer-dark"; # added to ./home.nix instead
            clock-format = "12h";
            clock-show-weekday = true;
            clock-show-seconds = true;
          };
          "org/gnome/desktop/calendar".show-weekdate = true; # add week numbers in calendar
          "org/gnome/desktop/background" = {
            color-shading-type = "solid";
            picture-options = "zoom";
            picture-uri = "file://" + wallpaper;
            picture-uri-dark = "file://" + wallpaper;
          };
          "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = true;
            night-light-schedule-from = 21.0;
            night-light-schedule-to = 6.0;
          };
          "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing"; # no suspend
          "org/gnome/desktop/session".idle-delay = lib.gvariant.mkUint32 1800; # screen off after 30mins
          "org/gnome/desktop/input-sources" = {
            sources = [
              (lib.gvariant.mkTuple [
                "xkb"
                "us"
              ])
              (lib.gvariant.mkTuple [
                "ibus"
                "mozc-jp"
              ])
            ];
          };
          "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
          "org/gnome/shell/extensions/paperwm" = {
            show-workspace-indicator = false; # show workspace pill indicator
            selection-border-radius-top = lib.gvariant.mkInt32 12;
            selection-border-radius-bottom = lib.gvariant.mkInt32 12;
          };
          "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "list-view";
            show-delete-permanently = true;
            sort-directories-first = false;
          };
          "org/gnome/desktop/search-providers".disabled = [ "org.gnome.Epiphany.desktop" ];
          "org/gnome/desktop/peripherals/mouse" = {
            accel-profile = "flat";
            speed = lib.gvariant.mkDouble 0.25;
          };
          "org/gnome/desktop/wm/keybindings" = {
            close = [
              "<Super>q"
              "<Alt>F4"
            ];
          };
          "org/gnome/shell/extensions/display-brightness-ddcutil" = {
            show-display-name = false;
            allow-zero-brightness = true;
            hide-system-indicator = true;
            button-location = lib.gvariant.mkInt32 1;
            increase-brightness-shortcut = [ "XF86MonBrightnessUp" ];
            decrease-brightness-shortcut = [ "XF86MonBrightnessDown" ];
          };
          "org/gnome/shell/extensions/copyous" = {
            show-at-pointer = true;
            auto-hide-search = true;
            clipboard-orientation = "vertical";
            clipboard-position-horizontal = "top";
            clipboard-position-vertical = "fill";
            dynamic-item-height = true;
            "file-item/file-preview-visibility" = "file-info";
            header-controls-visibility = "visible-on-hover";
            item-height = lib.gvariant.mkInt32 100;
            item-width = lib.gvariant.mkInt32 300;
            "link-item/link-preview-orientation" = "horizontal";
            show-header = false;
          };
        };
      }
    ];

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
      # gnome
      paperwm-patched
      gnomeExtensions.blur-my-shell
      gnomeExtensions.brightness-control-using-ddcutil
      ddcutil
      gnomeExtensions.copyous

      # qt theming
      qadwaitadecorations
      qadwaitadecorations-qt6
      qgnomeplatform
      qgnomeplatform-qt6

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
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
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
      darktable

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
