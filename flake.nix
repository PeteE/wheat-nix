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
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Hardware Configuration
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Generate System Images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Comma
    comma = {
      url = "github:nix-community/comma";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions/1a1442e13dc1730de0443f80dcf02658365e999a";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Vault Integration
    # vault-service = {
    #   url = "github:DeterminateSystems/nixos-vault-service";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Flake Hygiene
    flake-checker = {
      url = "github:DeterminateSystems/flake-checker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ollama = {
      url = "github:abysssol/ollama-flake/5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
    };
  };
  outputs = { self, ... }@inputs: inputs.snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;

    # snowfall metadata
    snowfall = {
      namespace = "wheat";
      meta = {
          name = "wheat";
          title = "PeteE's Flake";
      };
    };

    deploy = {
      # remoteBuild = true; # Uncomment in case the system you're deploying from is not darwin
      nodes.x1 = {
        hostname = "192.168.1.7";
        fastConnection = true;
        interactiveSudo = false;
        profiles = {
          system = {
            sshUser = "petee";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.x1;
            user = "petee";
          };
        };
      };
      nodes.m4 = {
        hostname = "m4";
        fastConnection = true;
        interactiveSudo = false;
        remoteBuild = true;
        profiles = {
          system = {
            path = inputs.deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.m4;
            user = "root";
            sshUser = "pete";
          };
        };
      };
    };
    # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;

    # overlays
    overlays = with inputs; [
      deploy-rs.overlays.default
      nix-vscode-extensions.overlays.default
      # mozilla.overlays.firefox
      # neovim.overlays.default
      # tmux.overlay
      # flake.overlays.default
      # thaw.overlays.default
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
      plasma-manager.homeManagerModules.plasma-manager
      nix-index-database.hmModules.nix-index
    ];

    systems = {
      overlays = with inputs; [
        mozilla.overlays.firefox
      ];

      modules = {
        darwin = with inputs; [
          home-manager.darwinModules.home-manager
        ];
        nixos = with inputs; [
          home-manager.nixosModules.home-manager
        ];
      };

      hosts = {
        x1.modules = with inputs; [
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
        ];
        pishield.modules = with inputs; [
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
        m4.modules = with inputs; [ ];
      };
    };
  };
}
