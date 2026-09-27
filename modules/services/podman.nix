{
  config,
  lib,
  ...
}:

let
  cfg = config.remote-deploy;
in
{
  options.podman = {
    enable = lib.mkEnableOption "podman support";
  };

  config = lib.mkIf cfg.enable {
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
  };
}
