{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./elenahaug.com.nix
  ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    virtualHosts."default" = {
      default = true;
      locations."/" = {
        return = "404";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "elena@elenahaug.com";
  };
}
