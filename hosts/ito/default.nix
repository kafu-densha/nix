{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./networking.nix
    ./disks.nix
    ./nvidia.nix
    ./audio.nix
    ./boot.nix
    ./tablet.nix
    ./vm.nix
    ./backup.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "data" ]; # auto import these pools on boot
  age.secrets.zfs-data-key = {
    rekeyFile = ../../secrets/master-keyed/zfs-data.key.age;
    path = "/etc/zfs/data.key";
    mode = "0400";
    owner = "root";
  };
  systemd.services."zfs-import-data" = {
    after = [ "agenix.service" ];
    wants = [ "agenix.service" ];
  };
  services.zfs.autoScrub.enable = true;

  # openrgb setup
  services.hardware.openrgb = {
    enable = true;
    startupProfile = "profile";
  };

  # fix crashes?
  boot.kernelParams = [
    "processor.max_cstate=1"
    "idle=nomwait"
  ];

  # add udev rules for flashing qmk firmware
  services.udev.packages = [ pkgs.qmk-udev-rules ];

  # enable i2c for monitor brightness control
  hardware.i2c.enable = true;

  # enable rasdaemon to monitor cpu crashes
  hardware.rasdaemon.enable = true;

  # Genshin (see https://github.com/ezKEa/aagl-gtk-on-nix)
  nix.settings = inputs.aagl.nixConfig;
  programs.anime-game-launcher.enable = true; # genshin
  programs.sleepy-launcher.enable = true; # zzz

  # Gaming
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [
      kdePackages.breeze # fix cursor theme
    ];
  };
  environment.systemPackages = with pkgs; [
    # Gaming
    lutris
    protonplus
    prismlauncher
    wineWow64Packages.stagingFull
    winetricks
    protontricks

    # add wake-in script
    (pkgs.writeShellScriptBin "wake-in" ''
      sudo sh -c "echo 0 > /sys/class/rtc/rtc0/wakealarm"
      sudo sh -c "echo \`date '+%s' -d '+ $1'\` > /sys/class/rtc/rtc0/wakealarm"
      sudo systemctl suspend
    '')
  ];

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

  graphical.enable = true;

  jellyfin.enable = true;

  system.stateVersion = "25.11";
}
