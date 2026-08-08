#!/bin/sh
# Prints what a repo expects of an issue before one is written: its issue
# templates (names, then decoded bodies), its labels, its most recent issues
# with their labels, and a duplicate search per keyword, pull requests included.
# Usage: show-repo-issues.sh <owner/repo> [keyword]...

set -eu

repo="${1:?usage: show-repo-issues.sh <owner/repo> [keyword]...}"
shift

section() { printf '\n== %s\n' "$1"; }

section "templates"
names=$(gh api "repos/$repo/contents/.github/ISSUE_TEMPLATE" --jq '.[].name' 2>/dev/null || true)
if [ -z "$names" ]; then
  echo "(none)"
else
  echo "$names" | while IFS= read -r name; do
    printf -- '--- %s\n' "$name"
    gh api "repos/$repo/contents/.github/ISSUE_TEMPLATE/$name" --jq '.content' | base64 -d
    echo
  done
fi

section "labels"
gh label list --repo "$repo" --limit 100 --json name,description \
  --jq '.[] | "\(.name)\t\(.description)"' 2>/dev/null || echo "(none)"

section "recent issues"
gh issue list --repo "$repo" --state all --limit 8 --json number,state,title,labels \
  --jq '.[] | "#\(.number) [\(.state)] \(.title) [\([.labels[].name] | join(", "))]"'

for keyword in "$@"; do
  section "search: $keyword"
  gh search issues --repo "$repo" --include-prs --limit 15 "$keyword" \
    --json number,state,title,isPullRequest,url \
    --jq '.[] | "#\(.number) [\(.state)]\(if .isPullRequest then " PR" else "" end) \(.title)\n  \(.url)"'
done
