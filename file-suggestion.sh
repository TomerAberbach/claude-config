#!/bin/bash
# No pipefail: `head -15` closing the pipe early would otherwise turn
# SIGPIPE from jj/find into a non-zero exit, triggering picker fallback
set -eu

query=$(jq -r '.query // ""')

# Outside a jj repo, exit non-zero so Claude Code falls back to its default picker
jj root > /dev/null 2>&1 || exit 1

# jj-tracked files first, then a plain find to surface ignored files jj won't list
list_files() {
  if [ -z "$query" ]; then
    # No query yet: files touched by the current change first
    jj diff --name-only 2> /dev/null
    jj file list
    all_files
  else
    {
      jj file list
      all_files
    } | grep -iF -- "$query"
  fi
}

all_files() {
  find . \( -name .jj -o -name .git \) -prune -o -type f -print 2> /dev/null |
    sed 's|^\./||'
}

list_files | awk '!seen[$0]++' | head -15
