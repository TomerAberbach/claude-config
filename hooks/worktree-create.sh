#!/bin/bash
set -euo pipefail

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
name=$(echo "$input" | jq -r '.name')

worktree_path="$cwd/.claude/worktrees/$name"
workspace_name="$name"

mkdir -p "$(dirname "$worktree_path")"

# All files appear "new" to a fresh workspace, so disable the limit for the
# initial snapshot to avoid false rejections on pre-existing large files.
jj workspace add "$worktree_path" --name "$workspace_name" --config 'snapshot.max-new-file-size="0"' >&2

echo "$worktree_path"
