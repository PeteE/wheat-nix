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
    ...
}:
{
  home = {
    username = config.snowfallorg.user.name;
  };
  wheat = {
    tmux.enable = true;
    kitty.enable = true;
    nushell.enable = true;
    nvim.enable = true;
    ripgrep.enable = true;
    secrets.enable = true;
    starship.enable = true;
    vscode.enable = true;
    zoxide.enable = true;
    azure.enable = true;
    carapace.enable = true;
    btop.enable = true;
    k9s.enable = true;
    attic-client.enable = true;
    firefox.enable = true;
    dev-tools.enable = true;
    ai.enable = true;
    # firefox.enable = true;

    # TODO: only enable on m4, x1
    embedded.enable = true;
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    OLLAMA_HOST = "m4.porcupine-python.ts.net";
  };

  home.packages = with pkgs; [
    meld # 3 way diff
    claude-code
    ollama
    dig
    bat
    openbao
    direnv
    curl
    wget
    nh
    git
    git-credential-manager
    fd
    bc
    attic-client
    # yazi
    # stylua
    yq-go
    glow
    delve
    links2
    presenterm
    asciinema
    # attic-server
    # clusterctl
    # mpv
    # clapper
    # nitrogen
    # lua5_3
    firefox
    vim
    tree
    slack
    slack-term
  ];
}
