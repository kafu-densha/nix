{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oidc;
  rootDomain = config.web.rootDomain;
  publicURL = "idm.${rootDomain}";
  services = [
    "vaultwarden"
  ];
  certDir = config.security.acme.certs."${rootDomain}".directory;
in
{
  options.oidc = {
    enable = lib.mkEnableOption "oidc server";
  };

  config = lib.mkIf cfg.enable {
    age.secrets = builtins.listToAttrs (
      map (service: {
        name = "service-${service}-secret";
        value = {
          owner = "kanidm";
          group = "kanidm";
          mode = "600";
          rekeyFile = ../secrets/kanidm/service-${service}-secret.age;
        };
      }) services
    );

    services.kanidm = {
      package = pkgs.kanidmWithSecretProvisioning_1_11;
      server = {
        enable = true;
        settings = {
          domain = publicURL;
          origin = "https://${publicURL}";

          # source: https://github.com/kanidm/kanidm/discussions/3349
          #   https://git.dblsaiko.net/systems/tree/configurations/vineta/kanidm.nix
          bindaddress = "[::1]:8443";
          http_client_address_info.x-forward-for = [ "::1" ];

          tls_key = "${certDir}/key.pem";
          tls_chain = "${certDir}/fullchain.pem";
        };
      };
      provision = {
        enable = true;
        groups.users.members = [ "elenah" ];
        persons.elenah = {
          displayName = "Elena";
          mailAddresses = [ "elena@elena.sh" ];
        };
        systems.oauth2 = {
          vaultwarden = {
            displayName = "Vaultwarden";
            originUrl = "https://vwp.${rootDomain}/identity/connect/oidc-signin";
            originLanding = "https://vwp.${rootDomain}";
            basicSecretFile = config.age.secrets.service-vaultwarden-secret.path;
            scopeMaps."users" = [
              "openid"
              "email"
              "profile"
            ];
          };
        };
      };
    };

    web.enable = lib.mkDefault true;

    services.nginx.virtualHosts."${publicURL}" = {
      useACMEHost = rootDomain;
      forceSSL = true;
      locations."/".proxyPass = "https://${config.services.kanidm.server.settings.bindaddress}";
    };

    security.acme.certs."${rootDomain}" = {
      extraDomainNames = [ publicURL ];
      reloadServices = [ "kanidm.service" ];
    };

    users.users."kanidm".extraGroups = [ "acme" ];
  };
}
