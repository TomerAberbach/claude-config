#!/bin/sh
# Prints what a repo expects of an issue before one is written: its contributing,
# security, and support guidelines, its issue templates (names, then decoded
# bodies), its labels, its most recent issues with their labels, and a duplicate
# search per keyword, pull requests included. For a guideline or template the
# repo lacks, it prints the one in the owner's `.github` repo, as GitHub does.
# Usage: show-repo-issues.sh <owner/repo> [keyword]...

set -eu

repo="${1:?usage: show-repo-issues.sh <owner/repo> [keyword]...}"
shift
org_repo="${repo%%/*}/.github"

section() { printf '\n== %s\n' "$1"; }

# Prints the filtered response of a GET, or nothing when the request fails.
api_or_nothing() {
  out=$(gh api "$1" --jq "$2" 2>/dev/null) && printf '%s\n' "$out" || true
}

# Prints the paths of the files in the directories GitHub searches for
# guidelines, in GitHub's order of precedence.
list_guideline_paths() {
  for dir in .github "" docs; do
    api_or_nothing "repos/$1/contents/$dir" '.[] | select(.type == "file") | .path'
  done
}

# Prints the first file among <paths> in <repo> named <name>, in any case and
# with any extension. Returns 1 when there is none.
# Usage: show_guideline <repo> <paths> <name>
show_guideline() {
  path=$(printf '%s\n' "$2" | grep -i "^\(.*/\)\{0,1\}$3\(\.[a-z]*\)\{0,1\}$" | head -n 1)
  [ -n "$path" ] || return 1
  printf -- '--- %s/%s\n' "$1" "$path"
  gh api "repos/$1/contents/$path" --jq '.content' | base64 -d
  echo
}

repo_paths=$(list_guideline_paths "$repo")
org_paths=$(list_guideline_paths "$org_repo")

for name in CONTRIBUTING SECURITY SUPPORT; do
  section "$name"
  show_guideline "$repo" "$repo_paths" "$name" ||
    show_guideline "$org_repo" "$org_paths" "$name" ||
    echo "(none)"
done

list_templates() {
  api_or_nothing "repos/$1/contents/.github/ISSUE_TEMPLATE" '.[].name'
}

section "templates"
template_repo="$repo"
names=$(list_templates "$repo")
if [ -z "$names" ]; then
  template_repo="$org_repo"
  names=$(list_templates "$org_repo")
fi
if [ -z "$names" ]; then
  echo "(none)"
else
  echo "$names" | while IFS= read -r name; do
    printf -- '--- %s/.github/ISSUE_TEMPLATE/%s\n' "$template_repo" "$name"
    gh api "repos/$template_repo/contents/.github/ISSUE_TEMPLATE/$name" --jq '.content' | base64 -d
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
