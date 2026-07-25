{
  config,
  pkgs,
  lib,
  ...
}:
let
  slack-mcp-server = pkgs.callPackage ./slack-mcp-server/package.nix { };
in
with lib;
let
  cfg = config.wheat.ai.mcp;
in
{
  options.wheat.ai.mcp = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      github-mcp-server
      playwright-mcp
      mcp-grafana
      mcp-nixos
      mcp-k8s-go
      slack-mcp-server
    ];
    sops.secrets.opGithubToken = { };
    sops.secrets.slack-mcp-server-oauth-user-token = { };
    programs.zsh = {
      envExtra = ''
        export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${config.sops.secrets.opGithubToken.path})"
        export SLACK_MCP_XOXP_TOKEN="$(cat ${config.sops.secrets.slack-mcp-server-oauth-user-token.path})"
      '';
    };
  };
}
