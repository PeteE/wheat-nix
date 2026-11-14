---
name: update-flake-inputs
description: Update one or all flake.nix inputs to the latest commit on their default branch and relock (build check optional via --build). Use when Pete asks to "update flake inputs", "bump nixpkgs", "update the flake", or "update <input-name>" in this wheat-nix repo. Every input here is pinned via `?ref=<commit-sha>` (see flake.nix), not a floating branch name, so "latest" always means resolving the default branch's current HEAD and rewriting that sha.
---

# Update flake inputs

All inputs in `flake.nix` are pinned to an exact commit via
`github:owner/repo?ref=<40-char-sha>`. There is no floating branch/tag to
just `nix flake update` against — updating means: look up the current HEAD
of each repo's default branch, and if it moved, rewrite the sha in
`flake.nix`, relock, and confirm the config still builds.

## Running it

Use the bundled script. It looks up each input, edits `flake.nix`, and runs a
single `nix flake lock`. It does **not** build by default. Pete prefers fast
turnaround: changes stay in the working tree and git is the undo button.

```bash
# update every github-type input
.claude/skills/update-flake-inputs/scripts/update-input.sh

# update just specific inputs
.claude/skills/update-flake-inputs/scripts/update-input.sh nixpkgs niri home-manager

# opt in to one build check after all updates
.claude/skills/update-flake-inputs/scripts/update-input.sh --build nixpkgs
```

`--build` builds the local host's system: `darwinConfigurations.<host>.system`
on macOS, `nixosConfigurations.<host>.config.system.build.toplevel` on Linux.
Override with `BUILD_TARGETS="<target> <target>"`. A failed build is reported
but nothing is reverted.

## What it does

1. Reads `nix flake metadata --json` to get each input's `owner`/`repo`/current
   pinned sha (skips anything not `type: github`, and anything not already
   pinned to a bare 40-char sha ref).
2. Resolves the repo's default-branch HEAD with `git ls-remote
   https://github.com/<owner>/<repo> HEAD`.
3. If changed, `sed`-replaces the old sha with the new one in `flake.nix`.
   Inputs sharing the same sha (e.g. `nixpkgs` and `nixpkgs-stable`) move
   together.
4. Runs one `nix flake lock` for all changed inputs.
5. With `--build`, runs the build target(s) once at the end.

## After it finishes

- Review: `git diff flake.nix flake.lock`. Revert: `git checkout flake.nix flake.lock`.
- Watch `home-manager` / `niri` bumps for breaking option changes.
- Nothing is auto-committed.

## Manual fallback (if you'd rather not use the script)

```bash
# find latest default-branch commit for one input
git ls-remote https://github.com/<owner>/<repo> HEAD

# edit flake.nix: replace the old ?ref=<sha> with the new one, then
nix flake lock --update-input <name>
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link
```
