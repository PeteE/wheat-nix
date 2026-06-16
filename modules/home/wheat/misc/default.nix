{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.wheat.misc;
in
{
  options.wheat.misc = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      meld
      inputs.deploy-rs.packages."${system}".deploy-rs # https://github.com/serokell/deploy-rs
      # ollama  # disabled: aarch64-darwin build requires Xcode + Metal toolchain
      bat
      openbao
      go_1_26
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
