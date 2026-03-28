{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ];

  programs.ssh.startAgent = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # Require pubkey auth
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Tailscale config
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # add tailscale CLI and podman config
  environment.systemPackages = with pkgs; [
    tailscale

    podman-compose
    slirp4netns
    fuse-overlayfs
  ];

  # Docker config
  virtualisation = {
    containers = {
      enable = true;
      registries.search = [ "docker.io" ];
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;

    };
  };
  users.users.elenah = {
    extraGroups = [ "podman" ];
    linger = true;
  };
  systemd.user.services.podman-restart = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "zfs-import-data.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.virtualisation.podman.package}/bin/podman start --all --filter restart-policy=always";
      RemainAfterExit = true;
    };
  };

}
