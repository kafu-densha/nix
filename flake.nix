{
  description = "NixOS flake for elena.ocf.berkeley.edu vm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, agenix, ... }@inputs: {
    nixosConfigurations.elena = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        agenix.nixosModules.default
      ];
    };
  };
}
