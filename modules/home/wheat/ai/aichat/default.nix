{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wheat.ai.aichat;
in {
  options.wheat.ai.aichat = {
    enable = mkEnableOption "Enable";
    settings = mkOption {
      type = types.attrs;
      default = {
        clients = [
          {
            type = "openai-compatible";
            name = "m4";
            api_base = "http://m4:8080/v1";
            models = [
              {
                name = "mistral-small-3.2";
                max_input_tokens = 8192;
                supports_function_calling = true;
              }
              # {
              #   name = "mlx-community/GLM-4-9B-0414-4bit";
              #   max_input_tokens = 8192;
              #   supports_function_calling = true;
              # }
            ];
          }
        ];
      };
      description = "Settings written to ~/.config/aichat/config.yaml";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];
    programs.aichat = {
      enable = true;
      settings = cfg.settings;
    };
    programs.zsh = {
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
        ${pkgs.wl-clipboard}/bin/wl-copy
        bindkey '\ee' _aichat_zsh
      '';
    };
  };
}
