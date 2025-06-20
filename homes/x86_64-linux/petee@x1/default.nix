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
    # All other arguments come from the home home.
    config,
    ...
}:
{
  # The only customizations here should be setting values that apply to this specific combination of x86_64 on a hostname called `x1`.
  # In other words, these should be pretty much empty
  wheat = {
    secrets.enable = true;  # enable SOPS secrets
    nushell.enable = true;  # enable nushell
    starship.enable = true;  # enable starship prompt
    tmux.enable = true;  # enable tmux
    nvim.enable = true;  # enable tmux
    zoxide.enable = true;  # enable zoxide fuzzy shell navigation (`cd` replacement)
    vscode.enable = true;  # enable vscode
    ripgrep.enable = true;  # enable ripgrep
    services.flameshot.enable = true; # enable flameshot (screenshot tool)
    services.ssh-agent.enable = true; # enable flameshot (screenshot tool)
    work.enable = true;
  };
  home.stateVersion = "25.11";
}
