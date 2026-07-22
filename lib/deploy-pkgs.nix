# vim: ts=2:sw=2:et
#
# deployPkgsFor <system>: a nixpkgs package set whose `deploy-rs` is the plain
# nixpkgs (cache.nixos.org) binary, while keeping deploy-rs's *flake* `lib`
# (the activate functions).
#
# Why this exists:
#   deploy-rs ships its `activate` binary as part of every deployed closure.
#   Calling `inputs.deploy-rs.lib.<system>.activate.*` directly uses deploy-rs's
#   own package, which — because we make deploy-rs follow our nixpkgs — is built
#   from source on a cache miss. On slow remote-build targets (rpi4) that
#   compile happens on the device itself. Swapping in the cached nixpkgs binary
#   avoids it. See the deploy-rs README ("binary caches" / overlay section).
#
# Used by flake.nix for the `deploy.nodes.*.profiles.system.path` definitions.
{ inputs, ... }:
{
  deployPkgsFor =
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    # First overlay (deploy-rs.overlays.default) puts deploy-rs's flake `lib`
    # onto pkgs, with the package wired through the pkgs fixpoint. The second
    # keeps that `lib` but swaps the underlying package for the cached nixpkgs
    # `deploy-rs`; because the lib resolves its binary via the fixpoint, the
    # activate scripts then use the cached binary instead of a source build.
    (pkgs.extend inputs.deploy-rs.overlays.default).extend (
      _: super: {
        deploy-rs = {
          inherit (pkgs) deploy-rs;
          lib = super.deploy-rs.lib;
        };
      }
    );
}
