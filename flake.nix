# vim: ts=2:sw=2:et
{
  description = "Pete's NixOS Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware Configuration
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Generate System Images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Snowfall Thaw
    thaw.url = "github:snowfallorg/thaw?ref=v1.0.4";

    # Comma
    comma = {
      url = "github:nix-community/comma";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System Deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Run unpatched dynamically compiled binaries
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Vault Integration
    vault-service = {
      url = "github:DeterminateSystems/nixos-vault-service";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake Hygiene
    flake-checker = {
      url = "github:DeterminateSystems/flake-checker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # disko = {
    #   url = "github:nix-community/disko/latest";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # }
  };
  outputs = inputs: inputs.snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;

    # snowfall metadata
    snowfall = {
      namespace = "petee";
      meta = {
          name = "wheat";
          title = "PeteE's Flake";
      };
    };

    # overlays
    overlays = with inputs; [
      # neovim.overlays.default
      # tmux.overlay
      # flake.overlays.default
      # thaw.overlays.default
      # cowsay.overlays.default
      # icehouse.overlays.default
      # attic.overlays.default
      # snowfall-docs.overlay
    ];
    channels-config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        # "electron-25.9.0"
      ];
    };

    homes.modules = with inputs; [
      sops-nix.homeManagerModules.sops
      catppuccin.homeModules.catppuccin
    ];

    systems = {
      modules = {
        darwin = with inputs; [
          # home-manager.darwinModules.home-manager
        ];

        nixos = with inputs; [
          home-manager.nixosModules.home-manager
          # nix-ld.nixosModules.nix-ld
          # disko.nixosModules.disko  # disk partitioning
        ];
      };

      hosts = {
        x1.modules = with inputs; [
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
        ];
      };
    };
  };
}
