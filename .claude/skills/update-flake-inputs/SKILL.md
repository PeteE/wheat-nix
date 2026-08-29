---
name: update-flake-inputs
description: Update one or all flake.nix inputs to the latest commit on their default branch, then verify the flake still builds. Use when Pete asks to "update flake inputs", "bump nixpkgs", "update the flake", or "update <input-name>" in this wheat-nix repo. Every input here is pinned via `?ref=<commit-sha>` (see flake.nix), not a floating branch name, so "latest" always means resolving the default branch's current HEAD and rewriting that sha.
---

# Update flake inputs

All inputs in `flake.nix` are pinned to an exact commit via
`github:owner/repo?ref=<40-char-sha>`. There is no floating branch/tag to
just `nix flake update` against — updating means: look up the current HEAD
of each repo's default branch, and if it moved, rewrite the sha in
`flake.nix`, relock, and confirm the config still builds.

## Running it

Use the bundled script — it does the lookup, edit, relock, and build-check,
and reverts automatically if the build breaks:

```bash
# update every github-type input
.claude/skills/update-flake-inputs/scripts/update-input.sh

# update just specific inputs
.claude/skills/update-flake-inputs/scripts/update-input.sh nixpkgs niri home-manager
```

By default it build-checks against `nixosConfigurations.$(hostname).config.system.build.toplevel`
(i.e. whichever host you're running it on — x1, ripnix, etc). Override with:

```bash
BUILD_TARGETS="nixosConfigurations.x1.config.system.build.toplevel nixosConfigurations.rpi4.config.system.build.toplevel" \
  .claude/skills/update-flake-inputs/scripts/update-input.sh
```

Darwin hosts (m4, m3p) can't be built from a Linux machine without a remote
builder — skip them unless you're running this on a Mac or have `darwin`
remote build configured.

## What it does, per input

1. Reads `nix flake metadata --json` to get each input's `owner`/`repo`/current
   pinned sha (skips anything not `type: github`, and anything not already
   pinned to a bare 40-char sha ref).
2. Resolves the repo's default-branch HEAD with `git ls-remote
   https://github.com/<owner>/<repo> HEAD`.
3. If unchanged, reports "up to date" and moves on.
4. If changed: `sed`-replaces the old sha with the new one in `flake.nix`
   (safe because a full commit sha is unique in the file), then
   `nix flake lock --update-input <name>`.
5. Runs the build-check target(s). On success, leaves the changes staged for
   review/commit. On failure, reverts `flake.nix` and `flake.lock` for that
   input and reports it as failed — other inputs in the same run are
   unaffected.

## After it finishes

- Review the diff (`git diff flake.nix flake.lock`) before committing —
  especially for inputs like `home-manager` or `niri` that can carry
  breaking option changes.
- Anything reported as `failed (build, reverted)` needs a manual look: the
  new upstream commit broke evaluation or the build. Read the tail of the
  build log the script printed, fix the fallout in the relevant module, or
  leave that input pinned and revisit later.
- Nothing is auto-committed — commit deliberately once you're happy with
  the diff.

## Manual fallback (if you'd rather not use the script)

```bash
# find latest default-branch commit for one input
git ls-remote https://github.com/<owner>/<repo> HEAD

# edit flake.nix: replace the old ?ref=<sha> with the new one, then
nix flake lock --update-input <name>
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link
```
