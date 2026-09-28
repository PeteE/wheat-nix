# vim: ts=2:sw=2:et
{
  description = "Pete's NixOS Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=241313f4e8e508cb9b13278c2b0fa25b9ca27163";
    nixpkgs-stable.url = "github:NixOS/nixpkgs?ref=4674dc7b68f722f217685a5c80564c0ed7c4a55a";
    home-manager = {
      url = "github:nix-community/home-manager?ref=6fa0edfe6a025d4d98f44a6c0d704d690dce3378";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib?ref=6ee3542cb459ca4b038cfe50ceb8797f05cdabad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix?ref=68f2670367e03da7d0cceef0594a7b2c173849de";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix?ref=2bd00bd9bb35fe6d114888c8f1c2e946c541dd8f";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin?ref=4cff07de74b50e64bdd68cd4e722ab5b6b35ee48";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hardware Configuration
    nixos-hardware = {
      url = "github:nixos/nixos-hardware?ref=30d48a0ec6035f8140d0125af274f0de95f1e9b5";
    };
    nur = {
      url = "github:nix-community/NUR?ref=acc660eb1096e33a452d632c731adaaf3f883fc4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake?ref=9ee3e13b60643448228353097880521658b2fe0e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell?ref=ad4c5a3817ccb096d20f948b67eeee8d8ba75be3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Generate System Images
    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # System Deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs?ref=e760371d631165e7d8de5b0dcf148e21ec4c16f0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    virby = {
      url = "github:quinneden/virby-nix-darwin?ref=a52216470a97ef5970939acf697a00ec61beb0c6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions?ref=86c56105e1e11b1d2a927e93bda8801088747aa2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix?ref=89b3eacf59d6b5eefbc2d69c3a4eb5aaf66d63bc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvirt = {
      url = "github:AshleyYakeley/NixVirt?ref=6d213ab42f72ba41c2eb4e6bdb97581c0642d942";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server?ref=2f984dfbe7e5271b5c413d3e734374cc1306c921";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix?ref=f10421316cc6df045497f5aa0009adce648e89ee";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llama-cpp = {
      url = "github:ggml-org/llama.cpp?ref=fcc891545b0f06de346d8f67d1e6c61f9bf0e777";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matthart1983-netwatch = {
      url = "github:matthart1983/netwatch?ref=554741876369772c496d3d2c4563ff1bd35bbc13";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-skills-opaque = {
      url = "git+ssh://git@github.com/opaque-systems/claude-skills.git";
      flake = false;
    };
  };
  outputs =
    { self, ... }@inputs:
    let
      # Builds deploy node `path`s with the cached nixpkgs deploy-rs binary
      # instead of a source build. See lib/deploy-pkgs.nix for the full rationale.
      inherit (import ./lib/deploy-pkgs.nix { inherit inputs; }) deployPkgsFor;
    in
    inputs.snowfall-lib.mkFlake {
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
          remoteBuild = true;
          profiles = {
            system = {
              sshUser = "petee";
              path = (deployPkgsFor "x86_64-linux").deploy-rs.lib.activate.nixos self.nixosConfigurations.x1;
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
              path = (deployPkgsFor "x86_64-linux").deploy-rs.lib.activate.nixos self.nixosConfigurations.ripnix;
              user = "root";
            };
          };
        };
        nodes.m4 = {
          hostname = "192.168.1.149";
          fastConnection = true;
          interactiveSudo = false;
          remoteBuild = true;
          profiles = {
            system = {
              path = (deployPkgsFor "aarch64-darwin").deploy-rs.lib.activate.darwin self.darwinConfigurations.m4;
              user = "root";
              sshUser = "pete";
            };
          };
        };
        nodes.m3p = {
          hostname = "192.168.1.210";
          fastConnection = true;
          interactiveSudo = false;
          remoteBuild = true;
          profiles = {
            system = {
              path = (deployPkgsFor "aarch64-darwin").deploy-rs.lib.activate.darwin self.darwinConfigurations.m3p;
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
              path = (deployPkgsFor "aarch64-linux").deploy-rs.lib.activate.nixos self.nixosConfigurations.rpi4;
              user = "root";
              sshUser = "petee";
            };
          };
        };
      };

      # overlays
      overlays = with inputs; [
        nix-vscode-extensions.overlays.default
        nur.overlays.default
        llama-cpp.overlays.default
        claude-code.overlays.default
        niri.overlays.niri
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
        noctalia.homeModules.default
        # Skip the home-manager manual. Its options.json builder force-evaluates
        # every module (surfacing unrelated deprecation warnings) and embeds the
        # nixpkgs source path without proper context. We don't use the on-disk
        # home-manager manual.
        {
          manual.html.enable = false;
          manual.json.enable = false;
          manual.manpages.enable = false;
        }
        {
          # Preserve current behavior (all catppuccin ports auto-enabled)
          # ahead of catppuccin/nix's enable/autoEnable split.
          catppuccin.enable = true;
          catppuccin.autoEnable = true;
        }
      ];

      systems = {
        modules = {
          darwin = with inputs; [
            sops-nix.darwinModules.sops
            home-manager.darwinModules.home-manager
            virby.darwinModules.default
          ];
          nixos = with inputs; [
            sops-nix.nixosModules.sops
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
                boot.binfmt.emulatedSystems = [
                  "armv6l-linux"
                  "aarch64-linux"
                ];
              }
            ];
          };

          ripnix.modules = with inputs; [
            niri.nixosModules.niri
          ];
          rpi4.modules = with inputs; [
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
          microvm-poc.modules = with inputs; [
            microvm.nixosModules.microvm
          ];
        };
      };
    };
}
