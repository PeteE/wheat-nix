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
    userName = config.snowfallorg.user.name;
    userEmail = "pete.perickson@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
  };
}
