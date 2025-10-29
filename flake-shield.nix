{
  description = "Simplified NixOS Shield configuration for fast evaluation";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Generate System Images
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.shield = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./systems/x86_64-linux/shield/default.nix
        {
          system.stateVersion = "25.05";
        }
      ];
    };

    packages.${system} = {
      azure-image = nixos-generators.nixosGenerate {
        inherit system;
        modules = [
          ./systems/x86_64-linux/shield/default.nix
          {
            system.stateVersion = "25.05";
          }
        ];
        format = "azure";
      };
    };
  };
}
