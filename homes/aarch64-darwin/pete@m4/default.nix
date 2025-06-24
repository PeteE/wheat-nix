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
    secrets.enable = true;  # enable SOPS secrets
    nushell.enable = true;  # enable nushell
    starship.enable = true;  # enable starship prompt
    tmux.enable = true;  # enable tmux
    nvim.enable = true;  # enable tmux
    zoxide.enable = true;  # enable zoxide fuzzy shell navigation (`cd` replacement)
    vscodium.enable = true;  # enable vscode
    ripgrep.enable = true;  # enable ripgrep
    #services.ssh-agent.enable = true;
    work.enable = true;
  };
  home.stateVersion = "25.11";
}
