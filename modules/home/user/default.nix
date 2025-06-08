{
    lib,
    pkgs,
    inputs,
    namespace, # The namespace used for your flake, defaulting to "internal" if not set.
    system, # The system architecture for this host (eg. `x86_64-linux`).
    target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
    format, # A normalized name for the system target (eg. `iso`).
    virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
    systems, # An attribute map of your defined hosts.
    config,
    ...
}:
{
  home = {
    username = config.snowfallorg.user.name;
    homeDirectory = "/home/${config.snowfallorg.user.name}";
    packages = with pkgs; [
      azure-storage-azcopy
      openbao
      usql
      links2
      presenterm
      kubectx
      asciinema
      cargo
      just
      postgresql_15
      oras
      git-credential-manager
      fd
      nodejs_22
      uv
      thumbs
      # siege
      podman
      skopeo
      openssl
      attic-server
      attic-client
      clusterctl
      github-cli
      mpv
      clapper
      nitrogen
      bc
      pinentry-rofi
      yazi
      niv
      nix-index
      devspace
      openvpn3
      virtualenv
      lua5_3
      stylua
      mpd
      firefox
      kubectl
      kubernetes-helm
      docker
      yadm
      ipcalc
      wireshark
      yq-go
      glow
      aria2
      nix-output-monitor
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
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
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
