{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.ai;
in {
  imports  = [
    ./mcp/mcp.nix
  ];

  options.wheat.ai = {
    enable = mkEnableOption "Enable";
    ollamaHost = mkOption {
      description = "ollama hostname";
      default = "127.0.0.1";
      type = types.str;
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code
      ollama
    ];
    sops.secrets.openaiApiKey = { };
    sops.secrets.anthropicApiKey = { };
    sops.secrets.assemblyAiApiKey = { };
    sops.secrets.opaqueGithubToken = { };
    programs.zsh = {
      envExtra = ''
        export OLLAMA_HOST=${cfg.ollamaHost}
        export OPENAI_API_KEY=$(cat ${config.sops.secrets.openaiApiKey.path})
        export ANTHROPIC_API_KEY=$(cat ${config.sops.secrets.anthropicApiKey.path})
        export ASSEMBLYAI_API_KEY=$(cat ${config.sops.secrets.assemblyAiApiKey.path})
        export OPAQUE_GITHUB_TOKEN=$(cat ${config.sops.secrets.opaqueGithubToken.path})
      '';
    };
  };
}
