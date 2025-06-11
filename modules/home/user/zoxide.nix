{ pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--no-aliases"
    ];
  };
}
