#!/usr/bin/env bash
# Update one or more github: flake inputs in flake.nix to the latest commit
# on their default branch and relock. By default no build is run — changes
# are left in the working tree for review (revert with git if needed).
#
# Usage:
#   update-input.sh                        # update every github-type input
#   update-input.sh nixpkgs niri           # update only the named inputs
#   update-input.sh --build nixpkgs        # also run one build check at the end
#
# Env:
#   BUILD_TARGETS  space-separated nix build targets used by --build
#                  (default: the local host's nixos/darwin system toplevel)

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

do_build=0
args=()
for a in "$@"; do
  case "$a" in
    --build) do_build=1 ;;
    *) args+=("$a") ;;
  esac
done

host="$(hostname -s)"
if [ "$(uname)" = "Darwin" ]; then
  default_target="darwinConfigurations.$host.system"
else
  default_target="nixosConfigurations.$host.config.system.build.toplevel"
fi
BUILD_TARGETS="${BUILD_TARGETS:-$default_target}"

metadata="$(nix flake metadata --json)"

mapfile -t all_inputs < <(jq -r '.locks.nodes.root.inputs | keys[]' <<<"$metadata")

if [ "${#args[@]}" -gt 0 ]; then
  targets=("${args[@]}")
else
  targets=("${all_inputs[@]}")
fi

# Inputs that track a branch other than the repo's default. nixpkgs master
# runs ahead of Hydra (uncached, sometimes broken); nixpkgs-unstable only
# advances after CI passes.
declare -A branches=(
  [nixpkgs]=nixpkgs-unstable
  [nixpkgs-stable]=nixpkgs-unstable
)

declare -A results
updated=()

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

  ref="HEAD"
  if [ -n "${branches[$name]:-}" ]; then
    ref="refs/heads/${branches[$name]}"
  fi

  latest="$(git ls-remote "https://github.com/$owner/$repo" "$ref" | cut -f1)"
  if [ -z "$latest" ]; then
    echo "  FAILED: could not resolve $ref for $owner/$repo"
    results["$name"]="failed (ls-remote)"
    continue
  fi

  if [ "$latest" = "$current" ]; then
    echo "  up to date (${current:0:12})"
    results["$name"]="up to date (${current:0:12})"
    continue
  fi

  echo "  ${current:0:12} -> ${latest:0:12}"

  sed -i "s/$current/$latest/" flake.nix

  if ! grep -q "$latest" flake.nix; then
    echo "  FAILED: sed didn't find $current in flake.nix (input url may not embed a bare ref=<sha>)"
    results["$name"]="failed (edit)"
    continue
  fi

  results["$name"]="updated ${current:0:12} -> ${latest:0:12}"
  updated+=("$name")
done

# One relock for everything that changed, rather than one per input.
if [ "${#updated[@]}" -gt 0 ]; then
  echo
  echo "== relocking: ${updated[*]} =="
  nix flake lock
fi

build_status=""
if [ "$do_build" = 1 ] && [ "${#updated[@]}" -gt 0 ]; then
  build_status="OK"
  for t in $BUILD_TARGETS; do
    echo "== building $t =="
    if ! nix build ".#$t" --no-link; then
      build_status="FAILED ($t)"
      break
    fi
  done
fi

echo
echo "== summary =="
for name in "${targets[@]}"; do
  printf '%-24s %s\n' "$name" "${results[$name]:-(not processed)}"
done
if [ -n "$build_status" ]; then
  echo "build: $build_status"
fi
if [ "${#updated[@]}" -gt 0 ]; then
  echo "review: git diff flake.nix flake.lock   revert: git checkout flake.nix flake.lock"
fi
