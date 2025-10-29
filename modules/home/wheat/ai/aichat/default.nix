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
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];
    programs.aichat = {
      enable = true;
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
