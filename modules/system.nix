{ config, lib, pkgs, ... }:

{
  imports = [];

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  users.users.elenah = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIK6PlfQq5LYIOHTnPwQvJeiGo3MYDxBRb+KdTqrffxFnAAAABHNzaDo= Yubikey"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6baI/1JPz2jJsMEiS6qxvpynLom7olVHMOGVjfBComkRSx6XvGSKRHYpSbA51LVtxdSwpheUWGD+x+JdSjwbxxBDjNafLKbTo+mI+SrTqDxYP3v/Ne9WZdd4tctwVbzEcDcR5nJtJPbB1VuYXcXovbBiqmu/VtRvtkWUo6LuVisnQIDtRI3QHTtKeIle4j/v3ApYBYTtW8XslxB7M7uhHYOpRsctDfZ0dH8VLpKEMJFGXIdHmFfZoT5DQshYvzbmb8hd6SCwewfYbFPp2+CycFxQbDzzQflmU4zsNS2EZavPhS6KPFnwcEmKz+8Y6z6iFQbvPFXoID71Uz7ldJcyb4KBxrkJQHRbZi0GKGSIX1hLFQBQjGPbIdFK9PTPLw0TTYd8fM+kM3yVwEuWPLcENunf5mVZBnW1zcSsk/S2nfgTNOwNzFia3QfvOevXujU3cVPHXLlYZ4L4bBeggbCsOLwmJhV7Fgr7kAcw5sWynZDrwBAHWijpPQE6m60EP8BM90JOyBSINEK/pZhxG5glkPSnIX6Jh83G+95hQs+LVVV214V0qhAM9Vaip4uHzCfcoDdgkXwaUs85/TV8ix5gh095mv5V5kJ6M22d5avjuJPc+aWibcn+vawcnokv+bLlWXzI6w6tYSXPE0FZoPdl8lytBsoB8cCFIrpqcRnJfDw== elenahaug@Blakes-MacBook-Pro.local"
    ];
  };
}
