#!/usr/bin/env bash
# Update one or more github: flake inputs in flake.nix to the latest commit
# on their default branch, then verify the flake still builds. Reverts
# flake.nix/flake.lock for any input whose build check fails.
#
# Usage:
#   update-input.sh                # update every github-type input
#   update-input.sh nixpkgs niri   # update only the named inputs
#
# Env:
#   BUILD_TARGETS  space-separated nix build targets used as the smoke test
#                  (default: the local host's nixosConfigurations toplevel)

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

default_target="nixosConfigurations.$(hostname).config.system.build.toplevel"
BUILD_TARGETS="${BUILD_TARGETS:-$default_target}"

metadata="$(nix flake metadata --json)"

mapfile -t all_inputs < <(jq -r '.locks.nodes.root.inputs | keys[]' <<<"$metadata")

if [ "$#" -gt 0 ]; then
  targets=("$@")
else
  targets=("${all_inputs[@]}")
fi

declare -A results

build_ok() {
  for t in $BUILD_TARGETS; do
    echo "  building $t ..." >&2
    if ! nix build ".#$t" --no-link 2>&1 | tail -40; then
      return 1
    fi
  done
}

for name in "${targets[@]}"; do
  echo "== $name =="

  nodeid="$(jq -r --arg n "$name" '.locks.nodes.root.inputs[$n] // empty' <<<"$metadata")"
  if [ -z "$nodeid" ]; then
    echo "  skip: no such input"
    results["$name"]="skip (unknown input)"
    continue
  fi

  orig="$(jq -c --arg n "$nodeid" '.locks.nodes[$n].original' <<<"$metadata")"
  type="$(jq -r '.type' <<<"$orig")"
  if [ "$type" != "github" ]; then
    echo "  skip: type=$type (only github: inputs are handled)"
    results["$name"]="skip (type=$type)"
    continue
  fi

  owner="$(jq -r '.owner' <<<"$orig")"
  repo="$(jq -r '.repo' <<<"$orig")"
  current="$(jq -r '.ref // empty' <<<"$orig")"

  if [ -z "$current" ] || ! [[ "$current" =~ ^[0-9a-f]{40}$ ]]; then
    echo "  skip: input isn't pinned via a commit-sha ref (current ref: ${current:-none})"
    results["$name"]="skip (not sha-pinned)"
    continue
  fi

  latest="$(git ls-remote "https://github.com/$owner/$repo" HEAD | cut -f1)"
  if [ -z "$latest" ]; then
    echo "  FAILED: could not resolve default-branch HEAD for $owner/$repo"
    results["$name"]="failed (ls-remote)"
    continue
  fi

  if [ "$latest" = "$current" ]; then
    echo "  up to date (${current:0:12})"
    results["$name"]="up to date (${current:0:12})"
    continue
  fi

  echo "  ${current:0:12} -> ${latest:0:12}"

  before_nix="$(cat flake.nix)"
  before_lock="$(cat flake.lock)"

  sed -i "s/$current/$latest/" flake.nix

  if ! grep -q "$latest" flake.nix; then
    echo "  FAILED: sed didn't find $current in flake.nix (input url may not embed a bare ref=<sha>)"
    printf '%s' "$before_nix" >flake.nix
    results["$name"]="failed (edit)"
    continue
  fi

  if ! nix flake lock --update-input "$name" >/tmp/update-flake-lock.$$ 2>&1; then
    echo "  FAILED: nix flake lock --update-input $name"
    tail -20 /tmp/update-flake-lock.$$
    printf '%s' "$before_nix" >flake.nix
    printf '%s' "$before_lock" >flake.lock
    results["$name"]="failed (lock)"
    rm -f /tmp/update-flake-lock.$$
    continue
  fi
  rm -f /tmp/update-flake-lock.$$

  if build_ok; then
    echo "  OK: updated and build verified"
    results["$name"]="updated ${current:0:12} -> ${latest:0:12}"
  else
    echo "  FAILED: build broke, reverting"
    printf '%s' "$before_nix" >flake.nix
    printf '%s' "$before_lock" >flake.lock
    results["$name"]="failed (build, reverted)"
  fi
done

echo
echo "== summary =="
for name in "${targets[@]}"; do
  printf '%-24s %s\n' "$name" "${results[$name]:-(not processed)}"
done
