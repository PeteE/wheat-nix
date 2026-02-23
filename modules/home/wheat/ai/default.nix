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
    ];
    
    # sops.secrets."aichat" = {
    #   path = "${config.home.homeDirectory}/.config/aichat/config.yaml";
    # };
    # programs.aichat = {
    #   enable = true;
    # };

    # home.sessionVariables = {
    #   OLLAMA_HOST = "192.168.1.115";
    # };

    sops.secrets.openrouerApiKey = { };
    sops.secrets.openaiApiKey = { };
    # sops.secrets.anthropicApiKey = { };
    sops.secrets.assemblyAiApiKey = { };
    sops.secrets.opaqueGithubToken = { };
    programs.zsh = {
      envExtra = ''
        export OLLAMA_HOST=${cfg.ollamaHost}
        export OPENAI_API_KEY=$(cat ${config.sops.secrets.openaiApiKey.path})
        export OPENROUTER_API_KEY=$(cat ${config.sops.secrets.openrouerApiKey.path})
        # export ANTHROPIC_API_KEY=""
        export ASSEMBLYAI_API_KEY=$(cat ${config.sops.secrets.assemblyAiApiKey.path})
        export OPAQUE_GITHUB_TOKEN=$(cat ${config.sops.secrets.opaqueGithubToken.path})
      '';
      completionInit = ''
        _aichat_zsh() {
          if [[ -n "$BUFFER" ]]; then
              local _old=$BUFFER
              BUFFER+="⌛"
              zle -I && zle redisplay
              BUFFER=$(aichat -e "$_old")
              zle end-of-line
          fi
        }
        zle -N _aichat_zsh
        wl-copy
        bindkey '\ee' _aichat_zsh
      '';
    };
  };
}
