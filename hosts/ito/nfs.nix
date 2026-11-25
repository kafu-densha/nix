_:

{
  # add bind mounts for nfs export
  fileSystems = {
    "/export" = {
      device = "/data";
      fsType = "none";
      options = [
        "rbind"
        "x-systemd.requires=zfs-mount.service"
        "x-systemd.after=zfs-mount.service"
        "x-systemd.before=nfs-server.service"
      ];
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export 100.64.0.0/10(rw,async,no_subtree_check,no_root_squash,crossmnt,fsid=0)
    '';
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 2049 ];
}
