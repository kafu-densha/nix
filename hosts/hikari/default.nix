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
    peripheralFirmwareDirectory = null; # use firmware from /boot/vendorfw
    avd = {
      enable = true;
      codecs = [ "all" ];
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

  services.niks3-auto-upload.enable = lib.mkForce false;

  nixpkgs.config.allowUnsupportedSystem = true;

  stats.enable = false;

  graphical = {
    enable = true;
    cosmic.enable = true;
  };
  programs.cosmic-nightlight.enable = true;

  # mount nfs
  fileSystems = {
    "/data" = {
      device = "ito:/export";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60" # unmount after 60 seconds of inactivity
        "noatime"
        "noauto"
        "_netdev"
      ];
    };
  };

  services.fail2ban.enable = lib.mkForce false;

  programs.steam-asahi = {
    enable = true;
    users = [ "elenah" ];
  };
  nixpkgs.config = {
    problems.handlers = {
      "gtk+".broken = "warn";
    };
  };

  system.stateVersion = "26.11";
}
