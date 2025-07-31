{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.wheat.ai;
in {
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
      opencommit
    ];

    home.file.".opencommit" = {
      text = ''
        OCO_AI_PROVIDER=ollama
        OCO_MODEL=mistral:7b  # gemma3:4b
        OCO_API_URL='http://192.168.1.115:11434/api/chat'
        OCO_API_KEY=undefined
        OCO_API_CUSTOM_HEADERS=undefined
        OCO_TOKENS_MAX_INPUT=4096
        OCO_TOKENS_MAX_OUTPUT=500
        OCO_EMOJI=false
        OCO_LANGUAGE=en
        OCO_MESSAGE_TEMPLATE_PLACEHOLDER=$msg
        OCO_PROMPT_MODULE=conventional-commit
        OCO_ONE_LINE_COMMIT=false
        OCO_TEST_MOCK_TYPE=commit-message
        OCO_GITPUSH=true
      '';
    };
    # sops.secrets."aichat" = {
    #   path = "${config.home.homeDirectory}/.config/aichat/config.yaml";
    # };
    programs.aichat = {
      enable = true;
    };

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
