{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.ai.opencommit;
in
{
  options.wheat.ai.opencommit = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      opencommit
    ];
    home.file.".opencommit" = {
      text = ''
        OCO_AI_PROVIDER=openai
        OCO_MODEL=mistral
        OCO_API_URL='http://m4:8080/'
        OCO_API_KEY=dummy
        OCO_TOKENS_MAX_INPUT=4096
        OCO_TOKENS_MAX_OUTPUT=500
        OCO_EMOJI=false
        OCO_LANGUAGE=en
        OCO_MESSAGE_TEMPLATE_PLACEHOLDER=$msg
        OCO_PROMPT_MODULE=conventional-commit
        OCO_ONE_LINE_COMMIT=false
        OCO_TEST_MOCK_TYPE=commit-message
        OCO_GITPUSH=false
      '';
    };
  };
}
