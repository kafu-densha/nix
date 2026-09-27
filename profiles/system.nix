{
  config,
  pkgs,
  inputs,
  pubkeys,
  self,
  lib,
  ...
}:

{
  # enable colmena
  remote-deploy.enable = lib.mkDefault true;

  # embed git commit in nixos-version
  system.configurationRevision = self.rev or self.dirtyRev or "dirty";
  system.nixos.label = "git-${self.shortRev or self.dirtyShortRev or "dirty"}";

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Setup shell
  environment.shells = with pkgs; [ zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = false; # don't override home-manager completion
  };

  # make sure users match this list
  users.mutableUsers = false;

  # main user setup
  age.secrets.elenah-password-hash.rekeyFile = ../secrets/master-keyed/elenah-password-hash.age;
  users.users.elenah = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "dialout"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = pubkeys;
    hashedPasswordFile = config.age.secrets.elenah-password-hash.path;
  };

  # setup niks3 push
  age.secrets.niks3-auth-token-client.rekeyFile = ../secrets/master-keyed/niks3-auth-token.age;
  services.niks3-auto-upload = {
    enable = true;
    package = inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3-hook;
    serverUrl = "https://niks3.kafu.observer";
    authTokenFile = config.age.secrets.niks3-auth-token-client.path;
  };
  environment.sessionVariables = {
    NIKS3_SERVER_URL = "https://niks3.kafu.observer";
    NIKS3_AUTH_TOKEN_FILE = config.age.secrets.niks3-auth-token-client.path;
  };

  # set nix oom settings
  systemd = {
    services = {
      "nix-daemon".serviceConfig = {
        Slice = "nix-daemon.slice";
        OOMScoreAdjust = 1000;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Essential Packages (All others are in home/default.nix)
    vim
    wget
    tree
    htop
    fastfetch
    git
    dig

    # Cache
    inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3

    nixos-firewall-tool

    tailscale

    podman-compose
    slirp4netns
    fuse-overlayfs
  ];

  programs.mosh.enable = true;

  programs.nix-index-database.comma.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/elenah/.nixos";
  };

  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      cores = 0;
      max-jobs = "auto";
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };

  programs.tmux.enable = true;
  programs.screen.enable = true;

  environment.shellAliases = {
    switch = "cd ~/.nixos && git pull && nh os switch && cd -";
  };

  programs.ssh.startAgent = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # Require pubkey auth
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  # Tailscale config
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
    extraSetFlags = [
      "--accept-routes" # ronri has routes configured in ronri/networking.nix
    ];
  };

  services.fail2ban.enable = true;
  networking.firewall = {
    logRefusedConnections = false;
    logRefusedPackets = false;
  };

  # enable stats reporting to grafana
  stats.enable = lib.mkDefault true;

  podman.enable = lib.mkDefault true;
}
