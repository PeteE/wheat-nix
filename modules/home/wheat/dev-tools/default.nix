{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.dev-tools;
in {
  options.wheat.dev-tools = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      delve
      usql
      podman
      just
      cargo
      skopeo
      openssl
      github-cli
      yq-go
      dig
      tcpdump
      oras
      uv
      nodejs_24
      postgresql_18
      vim
      lego
      jq
    ];
  };
}
