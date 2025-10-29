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
        # userSettings = {
        #   # This property will be used to generate settings.json:
        #   # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
        #   "editor.formatOnSave" = false;
        #   "workbench.colorTheme" = "Dracula Theme";
        # };
        # keybindings = [
        #   # See https://code.visualstudio.com/docs/getstarted/keybindings#_advanced-customization
        #   # {
        #   #   key = "shift+cmd+j";
        #   #   command = "workbench.action.focusActiveEditorGroup";
        #   #   when = "terminalFocus";
        #   # }
        # ];

        # Some extensions require you to reload vscode, but unlike installing
        # from the marketplace, no one will tell you that. So after running
        # `darwin-rebuild switch`, make sure to restart vscode!
        extensions = with pkgs; [
          # Search for vscode-extensions on https://search.nixos.org/packages

          # themes
          vscode-marketplace.catppuccin.catppuccin-vsc
          # vscode-marketplace.dracula-theme.theme-dracula
          # vscode-marketplace.github.github-vscode-theme

          # utilities
          vscode-marketplace-release.ms-vscode-remote.remote-ssh

          # makefile
          vscode-marketplace.ms-vscode.makefile-tools

          # embedded stuff
          # vscode-marketplace.platformio.platformio-ide

          # nix
          vscode-marketplace.jnoortheen.nix-ide

          # python
          vscode-marketplace.ms-python.python

          # go
          vscode-marketplace.golang.go

          # rust
          vscode-marketplace.rust-lang.rust-analyzer

          # psql
          vscode-marketplace.ms-ossdata.vscode-pgsql

          # Azure Resource Groups
          vscode-marketplace.ms-azuretools.vscode-azureresourcegroups

          # Azure Storage
          vscode-marketplace.ms-azuretools.vscode-azurestorage

          # Azure VMs
          vscode-marketplace.ms-azuretools.vscode-azurevirtualmachines

          # k8s
          vscode-marketplace.ms-kubernetes-tools.vscode-kubernetes-tools
          vscode-marketplace.ms-kubernetes-tools.vscode-aks-tools

          # nvim -- needs work
          vscode-marketplace.asvetliakov.vscode-neovim

          # justfile
          vscode-marketplace.nefrob.vscode-just-syntax

          vscode-marketplace.github.vscode-github-actions
          vscode-marketplace.github.vscode-pull-request-github
          # vscode-marketplace.github.copilot
          # vscode-marketplace.github.copilot-chat
          vscode-marketplace.anthropic.claude-code

          # terraform/terragrunt
          vscode-marketplace.hashicorp.terraform
          vscode-marketplace.stufftdsays.terraform-mermaid-visualizer
          vscode-marketplace.bahramjoharshamshiri.hcl-lsp

          # yaml syntax
          vscode-marketplace.redhat.vscode-yaml

          # helm
          vscode-marketplace.tim-koehler.helm-intellisense

          # argocd
          # vscode-marketplace.adityasinghal26.argocd

          # nushell
          vscode-marketplace.thenuprojectcontributors.vscode-nushell-lang
          # repomix
          vscode-marketplace.dorianmassoulier.repomix-runner
        ];
      };
    };
  };
}
