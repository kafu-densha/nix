{
  config,
  lib,
  ...
}:

let
  cfg = config.forgejo;
  srv = config.services.forgejo.settings.server;
  rootDomain = config.web.rootDomain;
  publicURL = "git.${rootDomain}";
in
{
  options.forgejo = {
    enable = lib.mkEnableOption "forgejo server";
  };

  config = lib.mkIf cfg.enable {

    age.secrets.forgejo-admin-password = {
      owner = "forgejo";
      group = "forgejo";
      mode = "600";
      rekeyFile = ../../secrets/master-keyed/forgejo-admin-password.age;
    };

    services.forgejo = {
      enable = true;
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = publicURL;
          ROOT_URL = "https://${srv.DOMAIN}/";
          HTTP_PORT = 3000;
          SSH_PORT = lib.head config.services.openssh.ports;
        };
        service = {
          DISABLE_REGISTRATION = false;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
          ENABLE_INTERNAL_SIGNIN = false;
        };
        oauth2_client = {
          OPENID_CONNECT_SCOPES = "email profile";
        };
      };
    };

    web.enable = lib.mkDefault true;

    # NGINX config
    services.nginx.virtualHosts."${publicURL}" = {
      useACMEHost = rootDomain;
      forceSSL = true;
      extraConfig = ''
        client_max_body_size 512M;
      '';
      locations."/".proxyPass = "http://127.0.0.1:${toString srv.HTTP_PORT}";
    };
    security.acme.certs."${rootDomain}".extraDomainNames = [ publicURL ];
  };
}
