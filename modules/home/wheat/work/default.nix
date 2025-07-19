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
    ...
}:
with lib; let
  cfg = config.wheat.work;
in {
  # This module will contain any work-related stuff
  options.wheat.work = with types; {
    enable = mkEnableOption "Enable work-related stuff";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      azure-cli
      azure-storage-azcopy
      k9s
      terragrunt
      opentofu
      openbao
      argo
      kubernetes-helm
      k9s
      fzf
      fasd
    ];
    # zsh stuff
    programs.zsh.shellAliases = {
      k = "kubectl";
      # TODO
      # az_switch = "az account list --all --output tsv --query '[*].name' 2> /dev/null | fzf";
    };
  };
}
