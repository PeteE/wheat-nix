#!/usr/bin/env bash
# Interactively delete kubeconfig contexts, clusters and users with fzf.
#
# Usage: kube-prune.sh [contexts|orphans]
#   contexts (default)  pick contexts; their cluster/user are removed too
#                       unless another remaining context still uses them
#   orphans             pick clusters/users not referenced by any context
#
# Uses $KUBECONFIG (first path) or ~/.kube/config. A timestamped backup
# is written next to the kubeconfig before any change.
set -euo pipefail

for bin in kubectl jq fzf; do
  command -v "$bin" >/dev/null || { echo "missing: $bin" >&2; exit 1; }
done

KCFG="${KUBECONFIG:-$HOME/.kube/config}"
KCFG="${KCFG%%:*}"
export KUBECONFIG="$KCFG"
MODE="${1:-contexts}"

json() { kubectl config view -o json; }

backup() {
  local b
  b="$KCFG.bak-$(date +%Y%m%d-%H%M%S)"
  cp -p "$KCFG" "$b"
  echo "backup: $b"
}

confirm() {
  local ans
  read -r -p "$1 [y/N] " ans
  [[ "$ans" == [yY]* ]]
}

prune_contexts() {
  local cfg current selected
  cfg=$(json)
  current=$(kubectl config current-context 2>/dev/null || true)

  # name<TAB>cluster<TAB>user<TAB>server, current context marked with *
  selected=$(jq -r --arg cur "$current" '
      (.clusters // []) as $cl
      | (.contexts // [])[]
      | .context.cluster as $c
      | [ (if .name == $cur then "*" else "-" end), .name,
          ($c // "-"),
          (.context.user // "-"),
          ([$cl[] | select(.name == $c) | .cluster.server][0] // "-") ]
      | @tsv' <<<"$cfg" |
    column -t -s $'\t' |
    fzf --multi --reverse --height=80% \
      --header=$'TAB select, ENTER confirm, ESC abort (* = current)\n  CONTEXT / CLUSTER / USER / SERVER' \
      --preview "kubectl config get-contexts {2}" --preview-window=down,3 |
    awk '{print $2}') || true

  [[ -z "$selected" ]] && { echo "nothing selected"; return; }

  echo "will delete contexts (plus unshared clusters/users):"
  sed 's/^/  /' <<<"$selected"
  confirm "proceed?" || { echo "aborted"; return; }
  backup

  local sel_json
  sel_json=$(jq -R . <<<"$selected" | jq -s .)
  # clusters/users still referenced by contexts we keep
  local keep
  keep=$(jq -c --argjson sel "$sel_json" '
      [(.contexts // [])[] | select(.name as $n | $sel | index($n) | not)]
      | {clusters: map(.context.cluster), users: map(.context.user)}' <<<"$cfg")

  jq -r --argjson sel "$sel_json" '
      (.contexts // [])[] | select(.name as $n | $sel | index($n))
      | [.name, (.context.cluster // "-"), (.context.user // "-")] | @tsv' <<<"$cfg" |
  while IFS=$'\t' read -r ctx cluster user; do
    kubectl config delete-context "$ctx" >/dev/null && printf 'context %s' "$ctx"
    if [[ "$cluster" != "-" ]]; then
      if jq -e --arg c "$cluster" '.clusters | index($c)' <<<"$keep" >/dev/null; then
        printf ' | kept shared cluster %s' "$cluster"
      else
        kubectl config delete-cluster "$cluster" >/dev/null 2>&1 && printf ' | cluster'
      fi
    fi
    if [[ "$user" != "-" ]]; then
      if jq -e --arg u "$user" '.users | index($u)' <<<"$keep" >/dev/null; then
        printf ' | kept shared user %s' "$user"
      else
        kubectl config delete-user "$user" >/dev/null 2>&1 && printf ' | user'
      fi
    fi
    echo
  done

  if grep -qxF "$current" <<<"$selected"; then
    echo "note: current context '$current' was deleted; run 'kubectl config use-context <name>'"
  fi
}

prune_orphans() {
  local cfg selected
  cfg=$(json)
  selected=$(jq -r '
      [(.contexts // [])[].context] as $ctx
      | ([$ctx[].cluster]) as $uc | ([$ctx[].user]) as $uu
      | ((.clusters // [])[] | select(.name as $n | $uc | index($n) | not) | "cluster\t" + .name),
        ((.users // [])[]    | select(.name as $n | $uu | index($n) | not) | "user\t" + .name)' <<<"$cfg" |
    fzf --multi --reverse --height=80% --delimiter=$'\t' \
      --header=$'Orphaned (unreferenced) entries. TAB select, ENTER confirm') || true

  [[ -z "$selected" ]] && { echo "nothing selected (or no orphans)"; return; }

  echo "will delete:"
  sed 's/^/  /' <<<"$selected"
  confirm "proceed?" || { echo "aborted"; return; }
  backup

  while IFS=$'\t' read -r kind name; do
    kubectl config "delete-$kind" "$name" >/dev/null && echo "$kind $name"
  done <<<"$selected"
}

case "$MODE" in
  contexts) prune_contexts ;;
  orphans) prune_orphans ;;
  -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//' ;;
  *) echo "unknown mode: $MODE (contexts|orphans)" >&2; exit 1 ;;
esac
