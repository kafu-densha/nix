{
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./trackpad.nix
  ];

  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = ./firmware;
    avd = {
      enable = true;
      vaapi-support = true;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.kernelParams = [ "appledrm.show_notch=1" ]; # show notch

  boot.supportedFilesystems = [ "zfs" ]; # enable zfs support

  zramSwap.enable = true;

  networking.hostName = "hikari";

  networking = {
    networkmanager.wifi.backend = "iwd";
    wireless = {
      enable = lib.mkForce false;
      iwd.enable = true;
    };
    hostId = "a1f88db0";
  };

  nixpkgs.config.allowUnsupportedSystem = true;

  stats.enable = false;

  graphical = {
    enable = true;
    cosmic.enable = true;
  };

  # mount nfs
  fileSystems = {
    "/data" = {
      device = "ito:/export";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "x-systemd.automount"
        "noauto"
        "_netdev"
      ];
    };
  };

  services.fail2ban.enable = lib.mkForce false;

  system.stateVersion = "26.11";
}
