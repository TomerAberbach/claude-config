#!/bin/bash
# Exit code 2 sends the output to Claude
FILE=$(jq -r '.tool_input.file_path')
case "$FILE" in
  "$CLAUDE_PROJECT_DIR"/*) ;;
  *) exit 0 ;;
esac
cd "$CLAUDE_PROJECT_DIR" || exit 1
node_modules/.bin/prettier --cache --write --ignore-unknown "$FILE" >&2 || exit 2
