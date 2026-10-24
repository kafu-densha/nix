{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:

let
  cfg = config.graphical;

  paperwm-patched = (
    pkgs.gnomeExtensions.paperwm.overrideAttrs (prevAttrs: {
      patches = (prevAttrs.patches or [ ]) ++ [
        ./paperwm-scroll-windows.patch
      ];
    })
  );

  text-scaling-factor = lib.gvariant.mkDouble (
    if (config.networking.hostName == "hikari") then 0.90 else 1.00
  );
in
{
  config = lib.mkIf (cfg.enable && cfg.gnome.enable) {
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

    # gnome
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
    environment.gnome.excludePackages = with pkgs; [ gnome-tour ];
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = [
        # FIXME: patch mozc to fix https://github.com/NixOS/nixpkgs/issues/576522
        #        remove when NixOS/Nixpkgs#531687 reaches unstable
        (import inputs.nixpkgs-small {
          inherit (pkgs.stdenv.hostPlatform) system;
        }).ibus-engines.mozc
      ];
    };
    # environment.sessionVariables.GTK_THEME = "Adwaita:dark";
    programs.dconf.profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions =
              with pkgs.gnomeExtensions;
              [
                paperwm-patched.extensionUuid
                blur-my-shell.extensionUuid
                copyous.extensionUuid
              ]
              ++ (lib.optionals (config.networking.hostName == "ito") [
                brightness-control-using-ddcutil.extensionUuid
              ])
              ++ (lib.optionals (config.networking.hostName == "hikari") [
                just-perfection.extensionUuid
              ]);
            favorite-apps = [
              "zen-beta.desktop"
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
            inherit text-scaling-factor;
          };
          "org/gnome/desktop/calendar".show-weekdate = true; # add week numbers in calendar
          "org/gnome/desktop/background" = {
            color-shading-type = "solid";
            picture-options = "zoom";
            picture-uri = "file://" + inputs.wallpaper;
            picture-uri-dark = "file://" + inputs.wallpaper;
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
            xkb-options = [
              "terminate:ctrl_alt_bksp" # not sure what this is
              "japan:kana_lock" # type with kana by default
            ];
          };
          "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
          "org/gnome/shell/extensions/paperwm" = {
            show-workspace-indicator = false; # show workspace pill indicator
            selection-border-radius-top = lib.gvariant.mkInt32 12;
            selection-border-radius-bottom = lib.gvariant.mkInt32 12;
            selection-border-size = lib.gvariant.mkInt32 8;
            window-gap = lib.gvariant.mkInt32 10;
            horizontal-margin = lib.gvariant.mkInt32 10;
            vertical-margin = lib.gvariant.mkInt32 10;
            vertical-margin-bottom = lib.gvariant.mkInt32 10;
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
          "org/gnome/shell/extensions/just-perfection" = {
            # don't have clock covered by notch on hikari
            clock-menu-position = lib.gvariant.mkInt32 2;
            clock-menu-position-offset = lib.gvariant.mkInt32 20;
          };
        };
      }
    ];

    environment.systemPackages = with pkgs; [
      # gnome
      paperwm-patched
      gnomeExtensions.blur-my-shell
      gnomeExtensions.brightness-control-using-ddcutil
      ddcutil
      gnomeExtensions.copyous
      gnomeExtensions.just-perfection

      # qt theming
      qadwaitadecorations
      qadwaitadecorations-qt6
      qgnomeplatform
      qgnomeplatform-qt6
    ];
  };
}
