{
  description = "NixOS flake for elenah nix machines";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    neovim-flake.url = "github:ArMonarch/Neovim-flake";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, agenix, agenix-rekey, home-manager, home-manager-unstable, neovim-flake, nix-index-database, nix-darwin, flake-utils, colmena, ... }@inputs:
  let
    pubkeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIK6PlfQq5LYIOHTnPwQvJeiGo3MYDxBRb+KdTqrffxFnAAAABHNzaDo=" # main yubikey
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPs3+fHihwZSBQVtoXffCtSSmBBDb/0NY+BPDIo+FKh9AAAABHNzaDo=" # backup yubikey
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3SnQlFllOIBsQmgGB8owAyKviKNoRvleS/eIbK4/8B" # hikari
    ];
  in
  {
    nixosConfigurations = {
      ronri = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs pubkeys; };
        modules = [
          ./hosts/ronri/default.nix
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          nix-index-database.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.elenah = ./home/default.nix;
          }
        ];
      };
      ito = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = { inherit inputs pubkeys; };
        modules = [
          ./hosts/ito/default.nix
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          nix-index-database.nixosModules.default
          home-manager-unstable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.elenah = ./home/default.nix;
          }
        ];
      };
    };
    darwinConfigurations.hikari = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs self; };
      modules = [
        ./hosts/hikari/default.nix
        # agenix.darwinModules.default
        # agenix-rekey.darwinModules.default
        nix-index-database.darwinModules.default
        home-manager-unstable.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.elenah = ./hosts/hikari/home.nix;
          home-manager.backupFileExtension = "hm-backup";
        }
      ];
    };
    
    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs { system = "x86_64-linux"; };
        nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) self.nixosConfigurations;
        nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) self.nixosConfigurations;
      };

      ronri = {
        imports = self.nixosConfigurations.ronri._module.args.modules;
        deployment = {
          targetHost = "ronri";
          targetUser = "elenah";
          buildOnTarget = true;
        };
      };

      # ito = {
      #   imports = self.nixosConfigurations.ito._module.args.modules;
      #   deployment = {
      #     targetHost = "ito";
      #     targetUser = "elenah";
      #     buildOnTarget = true;
      #   };
      # };
    };
    
    agenix-rekey = agenix-rekey.configure {
      userFlake = self;
      nixosConfigurations = self.nixosConfigurations;
      # darwinConfigurations = self.darwinConfigurations or { };
    };
  }
  
  // flake-utils.lib.eachDefaultSystem (system: rec {
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ agenix-rekey.overlays.default ];
    };
    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.agenix-rekey
        pkgs.age-plugin-fido2-hmac
        colmena.packages.${system}.colmena
      ];
    };
  });
}
