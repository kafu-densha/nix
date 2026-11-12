{
  config,
  lib,
  ...
}:

let
  cfg = config.web;
in
{
  options.web = {
    enable = lib.mkEnableOption "web config";

    acmeEmail = lib.mkOption {
      type = lib.types.str;
      default = "acme@kafu.observer";
    };

    rootDomain = lib.mkOption {
      type = lib.types.str;
      default = "kafu.observer";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;

        virtualHosts = {
          "default" = {
            default = true;
            rejectSSL = true; # required for default vhost to apply to ssl connections
            locations."/" = {
              return = "404";
            };
          };
        };
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      age.secrets.cloudflare-api-key.rekeyFile = ../secrets/master-keyed/cloudflare-api-key.age;

      users.users."nginx".extraGroups = [ "acme" ];
      security.acme = {
        acceptTerms = true;
        defaults = {
          email = cfg.acmeEmail;
          dnsProvider = "cloudflare";
          environmentFile = config.age.secrets.cloudflare-api-key.path;
        };
      };
    })
  ];
}
