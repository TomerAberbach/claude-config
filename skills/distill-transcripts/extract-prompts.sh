#!/bin/sh
# Prints one tab-separated line per human prompt in a project's transcripts:
#   <project>	<session id>	<timestamp>	<prompt, newlines collapsed>
# Drops subagent turns, hook and command scaffolding, tool results, task
# notifications, and compaction summaries.
# Usage: extract-prompts.sh [--all] [--max-chars N] [project directory, default: cwd]
#   --all          read every project under ~/.claude/projects
#   --max-chars N  truncate each prompt to N characters, marking how many were cut

set -eu

all=false
max_chars=0
dir=

while [ $# -gt 0 ]; do
  case "$1" in
    --all) all=true ;;
    --max-chars) shift; max_chars="${1:?--max-chars needs a number}" ;;
    --max-chars=*) max_chars="${1#--max-chars=}" ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) dir="$1" ;;
  esac
  shift
done

if [ "$all" = true ] && [ -n "$dir" ]; then
  echo "--all reads every project; drop the directory argument" >&2
  exit 2
fi

root="$HOME/.claude/projects"

# Reads the transcripts of one absolute project directory. `find` rather than a
# glob because project directory names begin with a dash.
extract() {
  find "$1" -maxdepth 1 -name '*.jsonl' -exec cat {} + | jq -r \
    --arg proj "$(basename -- "$1")" --argjson max "$max_chars" '
    select(.type == "user" and .isSidechain != true and .isMeta != true)
    | select(.message.content | type == "string")
    | (.message.content | sub("^\\s+"; "") | gsub("\\s+"; " ")) as $text
    | select($text | length > 0)
    | select($text | test("^<(local-command|command-message|command-name|command-args|bash-input|bash-stdout|user-prompt-submit-hook|system-reminder|task-notification)") | not)
    | select($text | test("^This session is being continued from a previous conversation") | not)
    | (if $max > 0 and ($text | length) > $max
       then $text[0:$max] + " …[+\(($text | length) - $max) chars]"
       else $text
       end) as $prompt
    | [$proj, .sessionId, .timestamp, $prompt]
    | @tsv'
}

if [ "$all" = true ]; then
  if [ ! -d "$root" ]; then
    echo "no transcript directory at $root" >&2
    exit 1
  fi
  found=false
  for project in "$root"/*; do
    [ -d "$project" ] || continue
    found=true
    extract "$project"
  done
  if [ "$found" = false ]; then
    echo "no transcripts under $root" >&2
    exit 1
  fi
else
  dir="${dir:-$(pwd)}"
  project="$root/$(printf '%s' "$dir" | sed 's/[^a-zA-Z0-9]/-/g')"
  if [ ! -d "$project" ]; then
    echo "no transcript directory for $dir at $project" >&2
    exit 1
  fi
  extract "$project"
fi
