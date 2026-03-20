{ config, lib, pkgs, ... }:

{
  imports = [];

  services.nginx.virtualHosts = {
    "www.elenahaug.com" = {
      useACMEHost = "elenahaug.com";
      forceSSL = true;
      globalRedirect = "elenahaug.com";
    };
    "elenahaug.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/elenahaug.com";
    };
    "elena.ocf.berkeley.edu" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/elenahaug.com";
    };
    "ronri.ocf.berkeley.edu" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/elenahaug.com";
    };
  };

  # Setup tls challenge
  age.secrets.cloudflare-api-key.file = ../../../secrets/cloudflare-api-key.age;
  security.acme.certs."elenahaug.com" = {
    dnsProvider = "cloudflare";
    environmentFile = config.age.secrets.cloudflare-api-key.path;
    webroot = null;

    extraDomainNames = [
      "www.elenahaug.com"
    ];
  };

  # Create web files dir
  systemd.tmpfiles.rules = [
    "d /var/www/elenahaug.com 0755 deploy nginx -"
  ];

  # create deploy user for elenahaug.com
  users.users.deploy = {
    isNormalUser = true;
    createHome = true;
    home = "/home/deploy";
    description = "GitHub Actions Deployment User";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/BzaxAtrueXUriQLlEFaM6c4QF1OKH4teqFVhtOU54 github-actions-deploy"
    ];
  };
}
