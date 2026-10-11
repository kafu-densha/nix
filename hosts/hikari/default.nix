{
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
  ];

  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = ./firmware;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "hikari";

  networking = {
    networkmanager.wifi.backend = "iwd";
    wireless = {
      enable = lib.mkForce false;
      iwd.enable = true;
    };
  };

  nixpkgs.config.allowUnsupportedSystem = true;

  stats.enable = false;

  graphical.enable = true;

  # mount nfs
  fileSystems = lib.mkMerge [
    {
      "/data" = {
        device = "ito:/export";
        fsType = "nfs";
        options = [
          "nfsvers=4.2"
          "x-systemd.automount"
          "noauto"
        ];
      };
    }
    (builtins.listToAttrs (
      map
        (dataset: {
          name = "/data/${dataset}";
          value = {
            device = "ito:/export/${dataset}";
            fsType = "nfs";
            options = [
              "nfsvers=4.2"
              "x-systemd.automount"
              "noauto"
            ];
          };
        })
        [
          "backups"
          "games"
          "media"
          "misc"
        ]
    ))
  ];

  system.stateVersion = "26.11";
}
