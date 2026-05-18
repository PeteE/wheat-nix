{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.wheat.ai.vllm;
in
{
  options.wheat.ai.vllm = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
    ];
  };
}
