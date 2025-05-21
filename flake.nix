# vim: ts=4:sw=2:et
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
  };
  outputs = inputs: inputs.snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;
    channels-config = {
      allowUnfree = true;
    };
    overlays = with inputs; [];
    systems.modules.nixos = with inputs; [

    ];
    homes.modules = with inputs; [
      home-manager.nixosModules.home-manager
      # self.nixos.common
      # self.nixos.users
    ];

    snowfall = {
      namespace = "petee";
      meta = {
          name = "petee";
          title = "PeteE's Flake";
      };
    };
  };
}
