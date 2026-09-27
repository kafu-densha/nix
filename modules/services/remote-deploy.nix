{
  config,
  lib,
  yubikeys ? [ ],
  ...
}:

let
  cfg = config.remote-deploy;
in
{
  options.remote-deploy = {
    enable = lib.mkEnableOption "remote deployment to this machine";
  };

  config = lib.mkIf cfg.enable {
    # deploy-user setup
    users.groups.deploy-user = { };
    nix.settings.trusted-users = [ "deploy-user" ];
    users.users.deploy-user = {
      isSystemUser = true;
      useDefaultShell = true; # system users don't have shells but one is required for colmena
      group = "deploy-user";
      description = "Colmena Nix Deploy User";
      openssh.authorizedKeys.keys = yubikeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFm4MatcYjQ8oK+rriBRh5kx1+rAaAtkh7P0b/otBm39"
      ];
    };

    # fix colmena apply needing interactive sudo password entry
    security.sudo.extraRules = [
      {
        users = [ "deploy-user" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
