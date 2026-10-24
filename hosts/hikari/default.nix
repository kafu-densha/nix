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

  # battery saving
  boot.kernel.sysctl = {
    "kernel.nmi_watchdog" = 0;
    "vm.dirty_writeback_centisecs" = 1500;
  };
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };

  system.stateVersion = "26.11";
}
