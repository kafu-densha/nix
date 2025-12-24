# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball { url = "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz"; sha256 = "1rzgy9qmrvh9l3jrcjv14kva8sj3imzrpm2vmwcfzp40bk9wdfb5"; };
in
{
  imports =
    [
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];
   
  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "elena"; # Define your hostname.

  networking.networkmanager.enable = true;

  networking.networkmanager.dns = "none";
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  networking.nameservers = [
    "2607:f140:8801::1:22"
    "169.229.226.22"
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];
  networking.domain = "ocf.berkeley.edu";
  networking.search = [ "ocf.berkeley.edu" ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # PLACED BY JAYSA FOR OCF DNS
  networking.interfaces.enp1s0.ipv4.addresses = [
    {
      address = "169.229.226.254";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "169.229.226.1";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  users.users.elenah = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIK6PlfQq5LYIOHTnPwQvJeiGo3MYDxBRb+KdTqrffxFnAAAABHNzaDo= Yubikey"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6baI/1JPz2jJsMEiS6qxvpynLom7olVHMOGVjfBComkRSx6XvGSKRHYpSbA51LVtxdSwpheUWGD+x+JdSjwbxxBDjNafLKbTo+mI+SrTqDxYP3v/Ne9WZdd4tctwVbzEcDcR5nJtJPbB1VuYXcXovbBiqmu/VtRvtkWUo6LuVisnQIDtRI3QHTtKeIle4j/v3ApYBYTtW8XslxB7M7uhHYOpRsctDfZ0dH8VLpKEMJFGXIdHmFfZoT5DQshYvzbmb8hd6SCwewfYbFPp2+CycFxQbDzzQflmU4zsNS2EZavPhS6KPFnwcEmKz+8Y6z6iFQbvPFXoID71Uz7ldJcyb4KBxrkJQHRbZi0GKGSIX1hLFQBQjGPbIdFK9PTPLw0TTYd8fM+kM3yVwEuWPLcENunf5mVZBnW1zcSsk/S2nfgTNOwNzFia3QfvOevXujU3cVPHXLlYZ4L4bBeggbCsOLwmJhV7Fgr7kAcw5sWynZDrwBAHWijpPQE6m60EP8BM90JOyBSINEK/pZhxG5glkPSnIX6Jh83G+95hQs+LVVV214V0qhAM9Vaip4uHzCfcoDdgkXwaUs85/TV8ix5gh095mv5V5kJ6M22d5avjuJPc+aWibcn+vawcnokv+bLlWXzI6w6tYSXPE0FZoPdl8lytBsoB8cCFIrpqcRnJfDw== elenahaug@Blakes-MacBook-Pro.local"
    ];
    packages = with pkgs; [
    ];
  };

  home-manager.users.elenah = { pkgs, ... }: {
      home.packages = [ ];

      # Git config
      programs.git = {
        enable = true;
        settings = {
         	user = {
         	  name = "Blake Haug";
         	  email = "elena@elenahaug.com";
         	};
          commit.gpgsign = true;
          gpg.format = "ssh";
          gpg.ssh.allowedsignersfile = "/home/elenah/.ssh/allowed_signers";
          user.signingkey = "/home/elenah/.ssh/id_ed25519.pub";
          init.defaultbranch = "main";
        };
      };

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "25.11";
    };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # Tools
    vim
    wget
    tree
    htop
    fastfetch
    git
    dig
    bat

    # Services
    tailscale
  ];

  environment.variables.EDITOR = "vim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open minecraft ports
  # networking.firewall.allowedTCPPorts = [ 25565 ];
  # networking.firewall.allowedUDPPorts = [ 25565 ];


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # Require pubkey auth
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Tailscale config
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  # Docker config
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Nginx config
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "www.elenahaug.com" = {
        useACMEHost = "elenahaug.com";
        forceSSL = true;
        globalRedirect = "elenahaug.com";
      };
      "elenahaug.com" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/elenahaug.com";
      };
      # "vm.elenahaug.com" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   root = "/var/www/elenahaug.com";
      # };
      "elena.ocf.berkeley.edu" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/elenahaug.com";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "elena@elenahaug.com";
    certs."elenahaug.com".extraDomainNames = [
      "www.elenahaug.com"
    ];
  };
  systemd.tmpfiles.rules = [
    "d /var/www/elenahaug.com 0755 deploy nginx -"
  ];

  # create deploy user for elenahaug.com
  users.users.deploy = {
    isNormalUser = true;
    createHome = true;
    home = "/home/deploy";
    description = "GitHub Actions Deployment User";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/BzaxAtrueXUriQLlEFaM6c4QF1OKH4teqFVhtOU54 github-actions-deploy"
    ];
  };


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
