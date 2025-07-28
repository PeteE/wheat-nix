{
  pkgs,
  home,
  ...
}:
{
  wheat = {
    ollama.enable = true;
    secrets = {
      enable = true;
      # this is dumb, UID is hardecoded :shrug:
      # https://discourse.nixos.org/t/access-nixos-sops-secret-via-home-manager/38909/13
      defaultSymlinkPath = "/run/user/502/secrets";
      defaultSecretsMountPoint = "/run/user/502/secrets.d";
    };
  };
  home.packages = with pkgs; [
    spotify
  ];
  home.stateVersion = "25.11";
}
