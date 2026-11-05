{
  config,
  lib,
  ...
}:

let
  cfg = config.jellyfin;
  rootDomain = config.web.rootDomain;
  jellyfinURL = "jellyfin.${rootDomain}";
  sonarrURL = "sonarr.${rootDomain}";
in
{
  options.jellyfin = {
    enable = lib.mkEnableOption "jellyfin server";
  };

  config = lib.mkIf cfg.enable {
    age.secrets.sonarr-api-key = {
      owner = "recyclarr";
      group = "recyclarr";
      mode = "600";
      generator.script = "base64";
      rekeyFile = ../secrets/master-keyed/sonarr-api-key.age;
    };

    age.secrets.sonarr-api-key-formatted = {
      owner = "sonarr";
      group = "media";
      mode = "600";
      rekeyFile = ../secrets/master-keyed/sonarr-api-key-formatted.age;
      generator = {
        dependencies = [ config.age.secrets.sonarr-api-key ];
        script =
          {
            lib,
            decrypt,
            deps,
            ...
          }:
          ''
            echo SONARR__AUTH__APIKEY=$(${decrypt} ${lib.escapeShellArg (builtins.head deps).file})
          '';
      };
    };

    users.groups.media = { };

    services = {
      jellyfin = {
        enable = true;
        hardwareAcceleration = {
          enable = true;
          type = "nvenc";
          device = "/dev/dri/by-path/pci-0000:2b:00.0-render";
        };
      };
      recyclarr = {
        enable = true;
        configuration = {
          sonarr.sonarr-main = {
            base_url = "http://127.0.0.1:8989";
            api_key._secret = config.age.secrets.sonarr-api-key.path;

            quality_definition.type = "anime";
            quality_profiles = [
              {
                trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # [Anime] Remux-1080p
                reset_unmatched_scores.enabled = true;
              }
            ];
            custom_format_groups = {
              add = [
                { trash_id = "f54985e5e96747cef58731f1cf4c9181"; }
                { trash_id = "35fb4585dcd9e2a5ac732e4309f5a45a"; }
              ];
            };
          };
        };
      };
      sonarr = {
        enable = true;
        environmentFiles = [
          config.age.secrets.sonarr-api-key-formatted.path
        ];
        group = "media"; # give sonarr perms to modify media files
      };
      transmission = {
        enable = true;
        group = "media";
        settings.umask = "002";
      };
    };

    web.enable = lib.mkDefault true;

    services.nginx.virtualHosts = {
      "${jellyfinURL}" = {
        useACMEHost = rootDomain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
      "${sonarrURL}" = {
        useACMEHost = rootDomain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8989";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };

    security.acme.certs."${rootDomain}".extraDomainNames = [
      jellyfinURL
      sonarrURL
    ];
  };
}
