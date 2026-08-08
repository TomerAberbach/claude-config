#!/bin/sh
# Files a draft as a new issue, or posts it as a comment on an existing one, and
# prints what landed. A draft's first line is a `# ` heading holding the title;
# the rest is the body. A comment draft has no heading.
# Usage: post-draft.sh <owner/repo> <draft.md> [--label <name>]...
#        post-draft.sh <owner/repo> <draft.md> --comment-on <issue number>

set -eu

repo="${1:?usage: post-draft.sh <owner/repo> <draft.md> [--label <name>]... | --comment-on <n>}"
draft="${2:?usage: post-draft.sh <owner/repo> <draft.md> [--label <name>]... | --comment-on <n>}"
shift 2

comment_on=
labels=
requested=
while [ $# -gt 0 ]; do
  case "$1" in
    --label)
      shift
      quoted=$(printf '%s' "${1:?--label needs a name}" | sed "s/'/'\\\\''/g")
      labels="$labels --label '$quoted'"
      requested="$requested$1
"
      ;;
    --comment-on) shift; comment_on="${1:?--comment-on needs an issue number}" ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done
eval "set -- $labels"

[ -f "$draft" ] || { echo "no such draft: $draft" >&2; exit 2; }

if [ -n "$comment_on" ]; then
  if [ -n "$requested" ]; then
    echo "--label applies only when creating an issue" >&2
    exit 2
  fi
  if head -n 1 "$draft" | grep -q '^# '; then
    echo "a comment draft must not start with a heading" >&2
    exit 2
  fi
  gh issue comment "$comment_on" --repo "$repo" --body-file "$draft"
  number="$comment_on"
else
  title=$(head -n 1 "$draft" | sed -n 's/^# //p')
  [ -n "$title" ] || { echo "the draft's first line must be a '# ' heading holding the title" >&2; exit 2; }
  body=$(mktemp)
  trap 'rm -f "$body"' EXIT
  tail -n +2 "$draft" | sed '1{/^$/d;}' > "$body"
  url=$(gh issue create --repo "$repo" --title "$title" --body-file "$body" "$@")
  number="${url##*/}"
fi

gh issue view "$number" --repo "$repo" --json number,state,title,url,labels,comments \
  --jq '"#\(.number) [\(.state)] \(.title)\n\(.url)\nlabels: \([.labels[].name] | join(", "))\ncomments: \(.comments | length)"'

# GitHub silently discards labels on a new issue when the author lacks triage
# access to the repo, so report any requested label that is missing.
if [ -n "$requested" ]; then
  applied=$(gh issue view "$number" --repo "$repo" --json labels --jq '.labels[].name')
  dropped=$(printf '%s' "$requested" | while IFS= read -r name; do
    printf '%s\n' "$applied" | grep -Fxq -- "$name" || printf '%s, ' "$name"
  done)
  if [ -n "$dropped" ]; then
    echo "warning: GitHub dropped the requested labels ${dropped%, }. Only users with triage access can label issues on $repo, so ask a maintainer to add them" >&2
  fi
fi
