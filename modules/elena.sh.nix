{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config."elena.sh";
  rootDomain = "dev.elena.sh";
  siteContent = inputs."elena.sh".packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options."elena.sh" = {
    enable = lib.mkEnableOption "hosting elena.sh";
  };

  config = lib.mkMerge [
    # enable elena.sh repo for cache access
    { niks3.extraRepos = [ "kafu-densha/elena.sh" ]; }

    (lib.mkIf cfg.enable {
      web.enable = lib.mkDefault true;

      services.nginx.virtualHosts = {
        "${rootDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = siteContent;
        };
        "www.${rootDomain}" = {
          useACMEHost = rootDomain;
          forceSSL = true;
          globalRedirect = rootDomain;
        };
      };

      security.acme.certs."${rootDomain}".extraDomainNames = [
        "www.${rootDomain}"
      ];
    })
  ];
}
