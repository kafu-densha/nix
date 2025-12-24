{
  description = "NixOS flake for elena.ocf.berkeley.edu vm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.elena = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
