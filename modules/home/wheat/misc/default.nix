{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat.misc;
  deployPkgs = import nixpkgs {
    inherit system;
    overlays = [
      deploy-rs.overlay # or deploy-rs.overlays.default
      (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
    ];
  };
in {
  options.wheat.misc = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      meld
      inputs.deploy-rs.packages."${system}".deploy-rs # https://github.com/serokell/deploy-rs
      ollama
      bat
      openbao
      go_1_24
      attic-client
      glow
      delve
      links2
      presenterm
      asciinema
      tree
      slack-term
      cachix
    ];
  };
}
