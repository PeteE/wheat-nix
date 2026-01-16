# vim: ts=2:sw=2:et
{
  description = "Pete's NixOS Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hardware Configuration
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Generate System Images
    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # System Deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    virby = {
      url = "github:quinneden/virby-nix-darwin?ref=be19793779852006fe6bc498f8670c954b4adf96";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions/4b5d357fd9b7ffce8fded947e3e4e883ed1b2109";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix/02dee881c3e644e2b561f407742f1fd927c40b83";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvirt = {
      url = "github:AshleyYakeley/NixVirt/v0.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
    deploy = {
      nodes.x1 = {
        hostname = "192.168.1.7";
        fastConnection = true;
        interactiveSudo = false;
        remoteBuild = false;
        profiles = {
          system = {
            sshUser = "petee";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.x1;
            user = "root";
          };
        };
      };
      nodes.ripnix = {
        hostname = "192.168.1.143";
        fastConnection = true;
        interactiveSudo = false;
        remoteBuild = true;
        profiles = {
          system = {
            sshUser = "petee";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.ripnix;
            user = "root";
          };
        };
      };
      nodes.m4 = {
        hostname = "192.168.1.115";
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
      nodes.m3p = {
        hostname = "192.168.1.209";
        fastConnection = true;
        interactiveSudo = false;
        remoteBuild = true;
        profiles = {
          system = {
            path = inputs.deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.m3p;
            user = "root";
            sshUser = "petee";
          };
        };
      };
      nodes.rpi4 = {
        hostname = "192.168.1.173";
        fastConnection = true;
        interactiveSudo = false;
        remoteBuild = true;
        profiles = {
          system = {
            path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rpi4;
            user = "root";
            sshUser = "petee";
          };
        };
      };
    };

    # overlays
    overlays = with inputs; [
      nix-vscode-extensions.overlays.default
      # grim-hyprland.overlays.default
      # waybar.overlays.default
      nur.overlays.default
      claude-code.overlays.default
      # flake.overlays.default
    ];

    channels-config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
      permittedInsecurePackages = [
        # "electron-25.9.0"
      ];

    };

    homes.modules = with inputs; [
      sops-nix.homeManagerModules.sops
      catppuccin.homeModules.catppuccin
      # hyprshell.homeModules.default
      noctalia.homeModules.default
    ];

    systems = {
      overlays = with inputs; [ ];
      modules = {
        darwin = with inputs; [
          sops-nix.darwinModules.sops
          home-manager.darwinModules.home-manager
          virby.darwinModules.default
        ];
        nixos = with inputs; [
          home-manager.nixosModules.home-manager
          # nixos-generators.nixosModules.all-formats
          nixvirt.nixosModules.default
          microvm.nixosModules.host
          vscode-server.nixosModules.default
        ];
      };

      hosts = {
        x1 = {
          modules = with inputs; [
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
            niri.nixosModules.niri
            {
              boot.binfmt.emulatedSystems = [ "armv6l-linux" "aarch64-linux"];
              # nixpkgs.config.allowUnsupportedSystem = true;
              # nixpkgs.hostPlatform.system = "armv6l-linux";
              # nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
            }
          ];
        };

        ripnix.modules = with inputs; [
          niri.nixosModules.niri
        ];
        rpi4.modules = with inputs; [
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
        rpiw.modules = with inputs; [ ];
        m4.modules = with inputs; [ ];
        m3p.modules = with inputs; [ ];
        microvm-poc.modules = with inputs; [
          microvm.nixosModules.microvm
        ];
      };
    };
  };
}
