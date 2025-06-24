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
    };
    home.packages = with pkgs.vscode-extensions; [
      b4dm4n.vscode-nixpkgs-fmt
      asvetliakov.vscode-neovim
    ];
  };
}
