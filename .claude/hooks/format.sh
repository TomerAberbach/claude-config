#!/bin/bash
FILE=$(jq -r '.tool_input.file_path')
cd "$CLAUDE_PROJECT_DIR" || exit 1
pnpm format:base --ignore-unknown "$FILE"
