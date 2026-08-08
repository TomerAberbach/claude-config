#!/bin/sh
# Prints one tab-separated line per tool call in a project's transcripts, from
# the main thread and from the subagents a session spawned:
#   <project>	<session id>	<timestamp>	<tool>	<signature>	<error>	<skill>	<agent>	<detail>
# The signature is normalized for aggregation: a Bash command reduces to its
# command word and subcommand, a file path to its project-relative path, a skill
# or agent to its name. <error> is "err" when the call returned an error and ""
# otherwise. <skill> is the skill that was running, and <agent> the subagent id,
# each empty when there was none. <detail> is the truncated raw input, for
# reading a cluster once counting has selected it, and for an Agent call it is
# the prompt the subagent was given, kept long enough to read. A subagent's
# calls are listed under the session that spawned it, so session counts cover
# both. Assistant prose and thinking are excluded.
# Usage: extract-actions.sh [--all] [--max-chars N] [--agent-chars N] [project directory, default: cwd]
#   --all            read every project under ~/.claude/projects
#   --max-chars N    truncate each detail to N characters (default 120, 0 for no limit)
#   --agent-chars N  truncate a subagent prompt to N characters (default 900, 0 for no limit)

set -eu

all=false
max_chars=120
agent_chars=900
dir=

while [ $# -gt 0 ]; do
  case "$1" in
    --all) all=true ;;
    --max-chars) shift; max_chars="${1:?--max-chars needs a number}" ;;
    --max-chars=*) max_chars="${1#--max-chars=}" ;;
    --agent-chars) shift; agent_chars="${1:?--agent-chars needs a number}" ;;
    --agent-chars=*) agent_chars="${1#--agent-chars=}" ;;
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

# Emits records of these kinds, joined downstream by tool-call id:
#   U <id> <project> <session> <timestamp> <tool> <signature> <skill> <agent> <detail>
#   E <id>
# A Bash signature is left empty here and filled in by the awk stage. The find
# recurses because a subagent's transcript is at <session>/subagents/*.jsonl.
extract() {
  find "$1" -name '*.jsonl' -exec cat {} + | jq -r \
    --arg proj "$(basename -- "$1")" \
    --argjson max "$max_chars" \
    --argjson agentmax "$agent_chars" '
    def collapse: gsub("\\s+"; " ") | sub("^\\s+"; "") | sub("\\s+$"; "");
    def clip($n): if $n > 0 and (length > $n) then .[0:$n] + "…" else . end;
    def relpath($cwd):
      if $cwd != null and startswith($cwd + "/") then .[($cwd | length) + 1:] else . end;

    if .type == "assistant" then
      (.cwd // null) as $cwd
      | .sessionId as $sid
      | .timestamp as $ts
      | (.attributionSkill // "") as $skill
      | (.agentId // "") as $agent
      | .message.content[]?
      | select(.type == "tool_use")
      | . as $call
      # A subagent prompt states a task in full, so it is kept long enough to
      # read rather than clipped to the width the counting tables need.
      | (if .name == "Bash" then ["", (.input.command // "" | collapse | clip($max))]
         elif .name == "Read" or .name == "Edit" or .name == "Write" or .name == "NotebookEdit"
           then [(.input.file_path // "?" | relpath($cwd)), ""]
         elif .name == "Skill" then [(.input.skill // "?"), (.input.args // "" | collapse | clip($max))]
         elif .name == "Agent" then [(.input.subagent_type // "general-purpose"),
                                     (.input.prompt // "" | collapse | clip($agentmax))]
         elif .name == "Grep" or .name == "Glob"
           then [(.input.path // "." | relpath($cwd)), (.input.pattern // "" | collapse | clip($max))]
         else ["", ""]
         end) as [$sig, $detail]
      | ["U", $call.id, $proj, $sid, $ts, $call.name, $sig, $skill, $agent, $detail]
      | @tsv

    elif .type == "user" then
      .message.content[]?
      | select(.type == "tool_result" and .is_error == true)
      | ["E", .tool_use_id]
      | @tsv
    else empty end'
}

# Normalizes Bash commands, joins the error flag, and drops the id column.
# Tool-call records are buffered because a result follows its call in the stream.
normalize() {
  awk -F'\t' -v OFS='\t' '
    function bash_signature(cmd,   words, n, i, w, limit, out) {
      sub(/^[ (]+/, "", cmd)
      # A separator of "&&", ";", or a newline the extract collapsed to a space.
      while ((match(cmd, /^cd [^ ;&]+ *(&&|;) +/) || match(cmd, /^cd [^ ;&]+ +/)) &&
             RLENGTH < length(cmd))
        cmd = substr(cmd, RLENGTH + 1)
      while (match(cmd, /^(env|command|nohup) +/) ||
             match(cmd, /^[A-Za-z_][A-Za-z0-9_]*=[^ ]* +/) ||
             match(cmd, /^timeout [^ ]+ +/)) cmd = substr(cmd, RLENGTH + 1)
      n = split(cmd, words, " ")
      if (n == 0) return "?"
      limit = 1
      if (words[1] ~ /^(jj|git|gh|pnpm|npm|npx|yarn|bun|deno|cargo|uv|pip|pip3|go|make|brew|nix|docker|kubectl|systemctl|dotnet)$/) limit = 2
      if (n >= 2 && words[2] ~ /^(run|exec|x)$/) limit = 3
      out = ""
      for (i = 1; i <= limit && i <= n; i++) {
        w = words[i]
        if (i > 1 && (w ~ /^-/ || w ~ /[|&;<>$]/)) break
        out = (out == "" ? w : out " " w)
      }
      return out
    }

    $1 == "E" { failed[$2] = 1; next }
    $1 == "U" {
      count++
      id[count] = $2; proj[count] = $3; sess[count] = $4; ts[count] = $5
      tool[count] = $6
      sig[count] = ($6 == "Bash") ? bash_signature($10) : $7
      skill[count] = $8; agent[count] = $9; detail[count] = $10
      next
    }
    END {
      for (i = 1; i <= count; i++)
        print proj[i], sess[i], ts[i], tool[i],
              tool[i] ":" (sig[i] == "" ? tool[i] : sig[i]),
              (id[i] in failed ? "err" : ""),
              skill[i], agent[i], detail[i]
    }'
}

# Project directories are resolved and validated before the pipeline, because a
# pipeline reports only its last command's status.
if [ "$all" = true ]; then
  if [ ! -d "$root" ]; then
    echo "no transcript directory at $root" >&2
    exit 1
  fi
  projects=$(find "$root" -maxdepth 1 -mindepth 1 -type d | sort)
  if [ -z "$projects" ]; then
    echo "no transcripts under $root" >&2
    exit 1
  fi
else
  dir="${dir:-$(pwd)}"
  projects="$root/$(printf '%s' "$dir" | sed 's/[^a-zA-Z0-9]/-/g')"
  if [ ! -d "$projects" ]; then
    echo "no transcript directory for $dir at $projects" >&2
    exit 1
  fi
fi

printf '%s\n' "$projects" | while IFS= read -r project; do
  [ -n "$project" ] || continue
  extract "$project"
done | normalize
