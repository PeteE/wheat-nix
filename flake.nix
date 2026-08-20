# vim: ts=2:sw=2:et
{
  description = "Pete's NixOS Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=241313f4e8e508cb9b13278c2b0fa25b9ca27163";
    nixpkgs-stable.url = "github:NixOS/nixpkgs?ref=ac62194c3917d5f474c1a844b6fd6da2db95077d";
    home-manager = {
      url = "github:nix-community/home-manager?ref=041a999e8c1c5b731913855909e68d30ca69b8e0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib?ref=6ee3542cb459ca4b038cfe50ceb8797f05cdabad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix?ref=fa5340ac684cdce8a22b6d4a0bcebb0cc999275e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix?ref=f1406619a3884cd5c47992a70b8b35c9c0fcb4c9";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin?ref=57a3171f94705599a2499248ca5758d5eb47c0e0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hardware Configuration
    nixos-hardware = {
      url = "github:nixos/nixos-hardware?ref=a017f5b72210026af5b3ac5949f08d94380a6fbd";
    };
    nur = {
      url = "github:nix-community/NUR?ref=65d694ac8f65a6395a948aee60032170dcd402df";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake?ref=4dfd38bad6150c07be6cc3fd7682787765092eea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell?ref=632e65e1e93dbe2fa281d3ee7c2aceef903e5578";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Generate System Images
    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # System Deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs?ref=6d3087eedff75a715b40c0e124ba15d2dd7bec28";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    virby = {
      url = "github:quinneden/virby-nix-darwin?ref=a52216470a97ef5970939acf697a00ec61beb0c6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions?ref=4b5d357fd9b7ffce8fded947e3e4e883ed1b2109";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix?ref=673f730d0fc8db3468c51575f1d3d777cc55e51f";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvirt = {
      url = "github:AshleyYakeley/NixVirt?ref=5dfe108fd859b122f9a96981cb6bc12297653d6c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server?ref=2f984dfbe7e5271b5c413d3e734374cc1306c921";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix?ref=da78262708d858861afbe1f68ea65fedda4054c4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llama-cpp = {
      url = "github:ggml-org/llama.cpp?ref=1a064ab0921238c1daa397d6f4a900ef33884de2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matthart1983-netwatch = {
      url = "github:matthart1983/netwatch?ref=2b5d9119a33c7198c19d537f22b35cd2de38b827";
      inputs.nixpkgs.follows = "nixpkgs";
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
        overlays = with inputs; [ ];
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
          m4.modules = with inputs; [ ];
          m3p.modules = with inputs; [ ];
          microvm-poc.modules = with inputs; [
            microvm.nixosModules.microvm
          ];
        };
      };
    };
}
