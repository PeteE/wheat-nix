{
    lib,
    pkgs,
    inputs,
    namespace,
    home,
    target,
    format,
    virtual,
    host,
    config,
    ...
}:
{
  wheat = {
    secrets.enable = true;
    nushell.enable = true;
    starship.enable = true;
    tmux.enable = true;
    nvim.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;  # enable ripgrep

    services.ssh-agent.enable = false; # not supported by nix-darwin?

    # vscode.enable = true;  # enable vscode
    # ripgrep.enable = true;  # enable ripgrep
    # services.flameshot.enable = true; # enable flameshot (screenshot tool)
    # work.enable = true;
  };
  home.stateVersion = "25.11";
}
