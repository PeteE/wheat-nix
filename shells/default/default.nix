# vim: ts=2:sw=2:et
# Default devShell for the wheat-nix flake, entered automatically by direnv
# (`.envrc` -> `use flake`). Snowfall maps shells/<name>/ to
# devShells.<system>.<name>, so this becomes devShells.<system>.default.
{
  pkgs,
  ...
}:
pkgs.mkShell {
  name = "wheat-nix";

  packages = with pkgs; [
    # Git hooks — .envrc runs `lefthook install` on entry.
    lefthook

    # Nix tooling
    nil # language server
    nixfmt # formatter (RFC 166 style; nixfmt-rfc-style is now an alias)
    statix # linter
    deadnix # dead-code finder

    # Secrets / deploy
    sops
    age
    deploy-rs
    nh
  ];
}
