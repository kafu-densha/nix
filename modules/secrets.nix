{ config, lib, pkgs, inputs, ... }:

let
  hostkeys = {
    ronri = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46UqcVxkdL8TeUiZBID7Tz3wjVhPw1SstvfH1hjyrR";
    ito = ""; # TODO add ito hostkey
  };
in
{
  imports = [];

  age.rekey = {
    hostPubkey = hostkeys.${config.networking.hostName};
    masterIdentities = [
      ../secrets/master-identities/yubikey-primary.pub
    ];
    storageMode = "local";
    localStorageDir = inputs.self + "/secrets/rekeyed/${config.networking.hostName}";
  };
}
