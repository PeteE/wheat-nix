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
      # ollama  # disabled: aarch64-darwin build requires Xcode + Metal toolchain
      bat
      openbao
      go_1_26
      attic-client
      glow
      delve
      presenterm
      asciinema
      tree
      slack-term
      cachix
    ];
  };
}
