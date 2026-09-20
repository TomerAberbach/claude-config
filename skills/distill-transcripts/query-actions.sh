#!/bin/sh
# Counts and filters the output of extract-actions.sh.
# Usage: query-actions.sh <query> <extract file> [signature]
#   sessions        sessions spanned per signature
#   failures        failed calls per signature
#   first-reads     files read among the first five Reads of each session,
#                   counted per session
#   sequences       runs of three signatures, consecutive repeats collapsed,
#                   counted once per session
#   skill-failures  failed calls per signature and running skill
#   signature SIG   session, error, skill, and detail of each call to SIG
#   agents          session, signature, and prompt of each subagent call
# Every query except signature and agents prints the top 30 rows.

set -eu

query="${1:?usage: query-actions.sh <query> <extract file> [signature]}"
file="${2:?usage: query-actions.sh <query> <extract file> [signature]}"

top() { sort | uniq -c | sort -rn | head -30; }

case "$query" in
  sessions)
    cut -f2,5 "$file" | sort -u | cut -f2 | top ;;
  failures)
    awk -F'\t' '$6 == "err"' "$file" | cut -f5 | top ;;
  first-reads)
    awk -F'\t' '$4 == "Read" { if (++n[$2] <= 5) print $5 "\t" $2 }' "$file" |
      sort -u | cut -f1 | top ;;
  sequences)
    awk -F'\t' '{ if ($2 != s) { s = $2; a = ""; b = ""; p = "" }
                  if ($5 == p) next
                  p = $5
                  if (a != "" && b != "") print a " > " b " > " $5 "\t" $2
                  a = b; b = $5 }' "$file" |
      sort -u | cut -f1 | top ;;
  skill-failures)
    awk -F'\t' '$6 == "err" && $7 != ""' "$file" | cut -f5,7 | top ;;
  signature)
    signature="${3:?signature needs a signature, such as 'Bash:uv run pytest'}"
    awk -F'\t' -v sig="$signature" '$5 == sig' "$file" | cut -f2,6,7,9 ;;
  agents)
    awk -F'\t' '$4 == "Agent"' "$file" | cut -f2,5,9 ;;
  *)
    echo "unknown query: $query" >&2; exit 2 ;;
esac
