{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.secrets;
  hostkeys = rec {
    ronri = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46UqcVxkdL8TeUiZBID7Tz3wjVhPw1SstvfH1hjyrR";
    ito = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILhtJOUxFnQicln/5h268GjBZbrRmFBv7xpa/nZ0JNwe";
    kako = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND/3tpoHWqbTw8DPBwmj1yq2LbPvZCiP1UG9+RHQAc+";
    hikari-darwin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFhFCahlkwdSAFyaemA8G6lYz3fnPJMP0da4cQyIyoy";
    hikari = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIyRR9B1Rm0X2b1LX58Bl93rcnIdSt7xlOqxLUObbTHF";
  };
in
{
  options.secrets = {
    enable = lib.mkEnableOption "agenix support on host";
  };

  config = lib.mkIf cfg.enable {
    age.rekey = {
      hostPubkey = hostkeys.${config.networking.hostName};
      masterIdentities = lib.filesystem.listFilesRecursive ../secrets/master-identities;
      storageMode = "local";
      localStorageDir = inputs.self + "/secrets/rekeyed/${config.networking.hostName}";
    };
  };
}
