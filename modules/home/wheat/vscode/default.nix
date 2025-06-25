# vim: ts=2:sw=2:et
{
    lib,
    pkgs,
    inputs,
    namespace,
    system,
    target,
    format,
    virtual,
    systems,
    config,
    modulesPath,
    ...
}:
with lib; let
  cfg = config.wheat.vscode;
in {
  options.wheat.vscode = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      profiles.default = {
        userSettings = {
          # This property will be used to generate settings.json:
          # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
          "editor.formatOnSave" = false;
          "workbench.colorTheme" = "Dracula Theme";
        };
        keybindings = [
          # See https://code.visualstudio.com/docs/getstarted/keybindings#_advanced-customization
          # {
          #   key = "shift+cmd+j";
          #   command = "workbench.action.focusActiveEditorGroup";
          #   when = "terminalFocus";
          # }
        ];

        # Some extensions require you to reload vscode, but unlike installing
        # from the marketplace, no one will tell you that. So after running
        # `darwin-rebuild switch`, make sure to restart vscode!
        extensions = with pkgs; [
          # Search for vscode-extensions on https://search.nixos.org/packages
          vscode-marketplace.dracula-theme.theme-dracula
          vscode-marketplace.jnoortheen.nix-ide
          vscode-marketplace-release.ms-vscode-remote.remote-ssh
          vscode-marketplace.ms-vscode.makefile-tools
          vscode-marketplace.ms-python.python

          # go
          vscode-marketplace.golang.go
          vscode-marketplace.ms-ossdata.vscode-pgsql
          vscode-marketplace.ms-azurecache.vscode-azurecache
          vscode-marketplace.ms-kubernetes-tools.vscode-kubernetes-tools
          vscode-marketplace.asvetliakov.vscode-neovim

          vscode-marketplace.github.github-vscode-theme
          vscode-marketplace.github.vscode-github-actions
          vscode-marketplace.github.vscode-pull-request-github
          vscode-marketplace.github.copilot
          vscode-marketplace.github.copilot-chat
          vscode-marketplace.anthropic.claude-code
        ];
      };
    };
  };
}
