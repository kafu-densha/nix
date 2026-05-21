{
  config,
  lib,
  ...
}:

let
  cfg = config.elenahaug-web;
in
{
  options.elenahaug-web = {
    enable = lib.mkEnableOption ''
      shared nginx + ACME setup for elenahaug.com sites. Provides a
      configured nginx (with a 404 default vhost), accepted ACME terms, and
      `security.acme.defaults` wired for Cloudflare DNS-01 — so any cert
      declared on this host via `security.acme.certs.<name>` (and referenced
      from a vhost via `useACMEHost`) inherits DNS-01 with no further
      boilerplate. The root `elenahaug.com` static site is opted into
      separately via `serveRoot`.
    '';

    acmeEmail = lib.mkOption {
      type = lib.types.str;
      default = "elena@elenahaug.com";
      description = "Contact email used for ACME registration.";
    };

    serveRoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Serve the root `elenahaug.com` static site (and the
        `www.elenahaug.com` → `elenahaug.com` redirect) from this host.
        Content lives at `/var/www/elenahaug.com` and is owned by the
        `deploy` user so GitHub Actions can rsync into it. Exactly one
        host should set this.
      '';
    };

    redirectDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "elena.ocf.berkeley.edu"
        "ronri.ocf.berkeley.edu"
      ];
      description = ''
        Additional domains that should 302-redirect to elenahaug.com. These
        aren't on Cloudflare-managed DNS, so they're issued via HTTP-01
        (nginx forces `dnsProvider = null` on `enableACME` certs, which is
        the desired behavior here).
      '';
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
            locations."/" = {
              return = "404";
            };
          };
        }
        // lib.genAttrs cfg.redirectDomains (_: {
          enableACME = true;
          forceSSL = true;
          globalRedirect = "elenahaug.com";
          redirectCode = 302;
        });
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      age.secrets.cloudflare-api-key.rekeyFile = ../secrets/cloudflare-api-key.age;

      security.acme = {
        acceptTerms = true;
        defaults = {
          email = cfg.acmeEmail;
          dnsProvider = "cloudflare";
          environmentFile = config.age.secrets.cloudflare-api-key.path;
        };
        certs."elenahaug.com".group = "nginx";
      };
    })

    (lib.mkIf (cfg.enable && cfg.serveRoot) {
      services.nginx.virtualHosts = {
        "elenahaug.com" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/elenahaug.com";
        };
        "www.elenahaug.com" = {
          useACMEHost = "elenahaug.com";
          forceSSL = true;
          globalRedirect = "elenahaug.com";
        };
      };

      # Declares the shared `elenahaug.com` cert (DNS-01 details come from
      # security.acme.defaults). Other modules on this host can piggyback
      # by appending to `extraDomainNames`.
      security.acme.certs."elenahaug.com".extraDomainNames = [
        "www.elenahaug.com"
      ];

      systemd.tmpfiles.rules = [
        "d /var/www/elenahaug.com 0755 deploy nginx -"
      ];

      users.users.deploy = {
        isNormalUser = true;
        createHome = true;
        home = "/home/deploy";
        description = "GitHub Actions Deployment User";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/BzaxAtrueXUriQLlEFaM6c4QF1OKH4teqFVhtOU54 github-actions-deploy"
        ];
      };
    })
  ];
}
