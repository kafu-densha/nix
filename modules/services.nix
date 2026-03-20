{ config, lib, pkgs, ... }:

{
  imports = [];

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
  # add tailscale CLI
  environment.systemPackages = with pkgs; [ tailscale ];

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
  users.users.elenah.extraGroups = ["podman"];

}
