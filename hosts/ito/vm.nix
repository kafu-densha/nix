{
  lib,
  ...
}:

{
  virtualisation.vmVariant = {
    virtualisation.memorySize = 8096;
    boot.zfs.extraPools = lib.mkForce [ ];
    users.users.elenah = {
      initialPassword = "test";
      hashedPasswordFile = lib.mkForce null;
    };
    hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion = true;
  };
}
