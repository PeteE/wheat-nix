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
{
  imports = [
    ./kitty.nix
    ./nvim.nix
    ./tmux/tmux.nix
    ./zoxide.nix
    ./starship/starship.nix
  ];

  home = {
    username = config.snowfallorg.user.name;
    packages = with pkgs; [
      azure-storage-azcopy
      links2
      presenterm
      asciinema
      # thumbs
      # attic-server
      # clusterctl
      # mpv
      # clapper
      # nitrogen

      # pinentry-rofi
      # nix-index
      # devspace
      # openvpn3
      # virtualenv
      firefox
      # wireshark
    ];
  };
  services.ssh-agent.enable = true;
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
    ];
  };
  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        logallrefupdates = true;
        ignorecase = true;
        precomposeunicde = true;
      };
      credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
    };
    userName = "Peter Erickson";
    userEmail = "pete.perickson@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
  };
}
