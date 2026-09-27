{
  config,
  lib,
  ...
}:

let
  cfg = config.jellyfin;
  rootDomain = config.web.rootDomain;
  publicURL = "jellyfin.${rootDomain}";
in
{
  options.jellyfin = {
    enable = lib.mkEnableOption "jellyfin server";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      hardwareAcceleration = {
        enable = true;
        type = "nvenc";
        device = "/dev/dri/by-path/pci-0000:2b:00.0-render";
      };
    };

    web.enable = lib.mkDefault true;

    services.nginx.virtualHosts = {
      "${publicURL}" = {
        useACMEHost = rootDomain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };

    security.acme.certs."${rootDomain}".extraDomainNames = [ publicURL ];
  };
}
