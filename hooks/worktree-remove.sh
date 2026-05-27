#!/bin/bash
set -euo pipefail

input=$(cat)
worktree_path=$(echo "$input" | jq -r '.worktree_path')

workspace_name=$(basename "$worktree_path")
repo_root=$(dirname "$(dirname "$worktree_path")")

cd "$repo_root"
jj workspace forget "$workspace_name" 2>&1 >&2 || true
rm -rf "$worktree_path"
