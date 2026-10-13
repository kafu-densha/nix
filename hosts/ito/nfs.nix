{
  lib,
  ...
}:

let
  zfs_datasets = [
    "backups"
    "games"
    "media"
    "misc"
    "photography"
  ];
in
{
  # add bind mounts for nfs export
  fileSystems = lib.mkMerge [
    {
      "/export" = {
        device = "/data";
        fsType = "none";
        options = [ "bind" ];
      };
    }
    (builtins.listToAttrs (
      map (dataset: {
        name = "/export/${dataset}";
        value = {
          device = "/data/${dataset}";
          fsType = "none";
          options = [ "bind" ];
        };
      }) zfs_datasets
    ))
  ];

  services.nfs.server = {
    enable = true;
    exports = ''
      /export 100.64.0.0/10(rw,async,no_subtree_check,no_root_squash,crossmnt)
    ''
    + builtins.concatStringsSep "\n" (
      map (
        dataset: "/export/${dataset} 100.64.0.0/10(rw,async,no_subtree_check,no_root_squash)"
      ) zfs_datasets
    );
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2049 ];
}
