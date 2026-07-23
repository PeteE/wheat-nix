{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.ai;
in
{
  imports = [
    ./mcp/mcp.nix
    ./skills.nix
    ./caveman.nix
  ];

  options.wheat.ai = {
    enable = mkEnableOption "Enable";
    ollamaHost = mkOption {
      description = "ollama hostname";
      default = "127.0.0.1";
      type = types.str;
    };
    claude.settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Declarative contents of ~/.claude/settings.json. Contributions from
        multiple modules (e.g. wheat.ai.caveman's hook wiring) are deep-merged
        by the module system. Only written to disk when `claude.manage` is true.
      '';
    };
    claude.manage = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether home-manager owns ~/.claude/settings.json (generated from
        claude.settings and symlinked from the nix store). When true, any
        changes made interactively via Claude Code's `/config` command are
        reverted on the next `home-manager switch`. Defaults off so hosts
        that hand-edit settings.json aren't surprised.
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code
    ];

    home.file = mkIf cfg.claude.manage {
      ".claude/settings.json".text = builtins.toJSON cfg.claude.settings;
    };

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
    sops.secrets.opGithubToken = { };
    programs.zsh = {
      envExtra = ''
        export OLLAMA_HOST=${cfg.ollamaHost}
        export OPENAI_API_KEY=$(cat ${config.sops.secrets.openaiApiKey.path})
        export OPENROUTER_API_KEY=$(cat ${config.sops.secrets.openrouerApiKey.path})
        # export ANTHROPIC_API_KEY=""
        export ASSEMBLYAI_API_KEY=$(cat ${config.sops.secrets.assemblyAiApiKey.path})
        export OP_GITHUB_TOKEN=$(cat ${config.sops.secrets.opGithubToken.path})
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
