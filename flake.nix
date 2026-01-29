{
  description = "NixOS flake for elena.ocf.berkeley.edu vm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-flake.url = "github:ArMonarch/Neovim-flake";
  };

  outputs = { self, nixpkgs, agenix, home-manager, neovim-flake, ... }@inputs: {
    nixosConfigurations.elena = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./modules/modules.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.elenah = ./modules/home/home.nix;
        }
      ];
    };
  };
}
