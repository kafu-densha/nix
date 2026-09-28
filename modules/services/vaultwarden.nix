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
    backup = lib.mkEnableOption "vaultwarden backup to hetzner vm";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      age.secrets.vaultwarden-env-file = {
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "600";
        rekeyFile = ../../secrets/master-keyed/vaultwarden-env-file.age;
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
    })
    (lib.mkIf (cfg.enable && cfg.backup) (
      let
        backupTemplate = {
          passwordFile = config.age.secrets.vaultwarden-backup-password.path;
          initialize = true;
          user = "vaultwarden";
          timerConfig = {
            OnCalendar = "*-*-* 03:00:00";
            Persistent = true;
            RandomizedDelaySec = "30min";
          };
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
          ];
          runCheck = true;
          paths = [ "/var/local/vaultwarden/backup" ];
        };
      in
      {

        age.secrets.vaultwarden-backup-password = {
          owner = "vaultwarden";
          group = "vaultwarden";
          mode = "600";
          generator.script = "base64";
          rekeyFile = ../../secrets/master-keyed/vaultwarden-backup-password.age;
        };

        age.secrets.hetzner-ssh-key = {
          owner = "vaultwarden";
          group = "vaultwarden";
          mode = "600";
          generator.script = "ssh-ed25519";
          rekeyFile = ../../secrets/master-keyed/hetzner-ssh-key.age;
        };

        services.restic.backups = {
          vaultwarden-backup-hetzner = backupTemplate // {
            repository = "sftp:u666620@u666620.your-storagebox.de:/home/restic/vaultwarden-backup";
            extraOptions = [
              "sftp.command='ssh -p 23 -o StrictHostKeyChecking=no u666620@u666620.your-storagebox.de -i ${config.age.secrets.hetzner-ssh-key.path} -s sftp'"
            ];
          };
        };
      }
    ))
  ];
}
