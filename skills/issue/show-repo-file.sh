#!/bin/sh
# Prints a file from a GitHub repo with line numbers, pinned to a commit, and
# the permalink prefix for citing its lines. Lists a directory when the path is
# one.
# Usage: show-repo-file.sh <owner/repo> <path> [ref, default: the default branch]
# Cite a line as <permalink prefix><line number>, e.g. ...#L74 or ...#L46-L54.

set -eu

repo="${1:?usage: show-repo-file.sh <owner/repo> <path> [ref]}"
path="${2:?usage: show-repo-file.sh <owner/repo> <path> [ref]}"
ref="${3:-$(gh api "repos/$repo" --jq '.default_branch')}"

sha=$(gh api "repos/$repo/commits/$ref" --jq '.sha')
json=$(gh api "repos/$repo/contents/$path?ref=$sha")

echo "ref: $ref"
echo "commit: $sha"

if [ "$(printf '%s' "$json" | jq -r 'type')" = "array" ]; then
  echo "directory: $path"
  echo
  printf '%s' "$json" | jq -r '.[] | "\(.type)\t\(.name)"'
  exit 0
fi

echo "permalink prefix: https://github.com/$repo/blob/$sha/$path#L"
echo
printf '%s' "$json" | jq -r '.content' | base64 -d | nl -ba -w4 -s '  '
