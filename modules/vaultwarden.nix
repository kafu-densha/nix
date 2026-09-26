{
  config,
  lib,
  ...
}:

let
  cfg = config.vaultwarden;
  rootDomain = config.web.rootDomain;
  publicURL = "vwp.${rootDomain}";
in
{
  options.vaultwarden = {
    enable = lib.mkEnableOption "vaultwarden hosting";
  };

  config = lib.mkIf cfg.enable {
    age.secrets.vaultwarden-env-file = {
      owner = "vaultwarden";
      group = "vaultwarden";
      mode = "600";
      rekeyFile = ../secrets/vaultwarden-env-file.age;
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      domain = publicURL;
      configureNginx = true;
      backupDir = "/var/local/vaultwarden/backup";
      environmentFile = config.age.secrets.vaultwarden-env-file.path;
      config = {
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";

        SSO_ENABLED = true;
        SSO_ONLY = true;
        SSO_AUTHORITY = "https://idm.${rootDomain}/oauth2/openid/vaultwarden";
        SSO_CLIENT_ID = "vaultwarden";
      };
    };

    web.enable = lib.mkDefault true;

    services.nginx.virtualHosts."${publicURL}" = {
      useACMEHost = rootDomain;
      forceSSL = true;
    };

    security.acme.certs."${rootDomain}".extraDomainNames = [ publicURL ];
  };
}
