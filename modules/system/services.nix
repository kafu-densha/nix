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
    useRoutingFeatures = "server";
  };
  # add tailscale CLI
  environment.systemPackages = with pkgs; [ tailscale ];

  # Docker config
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

}
