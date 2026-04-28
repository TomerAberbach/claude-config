#!/usr/bin/env bash
input=$(cat)

RESET=$'\033[0m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
GREEN=$'\033[38;5;71m'
YELLOW=$'\033[2;33m'
RED=$'\033[2;31m'
CYAN=$'\033[2;36m'
BRIGHT_CYAN=$'\033[36m'
BRIGHT_RED=$'\033[31m'

SEP="${DIM}│${RESET}"

model=$(echo "$input" | jq -r '.model.display_name // "Unknown model"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
max_tokens=$(echo "$input" | jq -r '.context_window.max_tokens // empty')
# Fall back to model-based lookup. All current Claude models are 200k.
if [ -z "$max_tokens" ] || [ "$max_tokens" = "0" ]; then
  model_id=$(echo "$input" | jq -r '.model.id // .model.api_name // empty' | tr '[:upper:]' '[:lower:]')
  case "$model_id" in
    *claude*) max_tokens=200000 ;;
  esac
fi

fmt_tokens() {
  local n=$1
  if [ "$n" -ge 1000 ]; then
    printf "%.1fk" "$(echo "scale=1; $n / 1000" | bc)"
  else
    printf "%d" "$n"
  fi
}

ctx_color() {
  local pct=$1
  if [ "$(echo "$pct >= 80" | bc)" = "1" ]; then
    printf "%s" "$RED"
  elif [ "$(echo "$pct >= 50" | bc)" = "1" ]; then
    printf "%s" "$YELLOW"
  else
    printf "%s" "$GREEN"
  fi
}

# Context health segment
ctx_seg="${DIM}ctx${RESET} ${DIM}--${RESET}"
if [ -n "$used_pct" ]; then
  color=$(ctx_color "$used_pct")
  warn=""
  [ "$(echo "$used_pct >= 80" | bc)" = "1" ] && warn=" ${BRIGHT_RED}⚠${RESET}"

  remaining=""
  if [ -n "$max_tokens" ] && [ "$max_tokens" -gt 0 ]; then
    used_abs=$(echo "$input" | jq -r '.context_window.used_tokens // empty')
    if [ -n "$used_abs" ]; then
      left=$((max_tokens - used_abs))
      remaining=" ${DIM}~$(fmt_tokens "$left") left${RESET}"
    else
      left=$(echo "scale=0; $max_tokens * (100 - $used_pct) / 100" | bc)
      remaining=" ${DIM}~$(fmt_tokens "$left") left${RESET}"
    fi
  fi

  ctx_seg="${DIM}ctx${RESET} ${color}$(printf "%.0f%%" "$used_pct")${RESET}${warn}${remaining}"
fi

in_fmt=$(fmt_tokens "$total_in")
out_fmt=$(fmt_tokens "$total_out")
tokens="${DIM}↑${RESET}${in_fmt} ${DIM}↓${RESET}${out_fmt}"

# Rate limits (Claude.ai subscribers)
limits_seg=""
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$five" ]; then
  color=$(ctx_color "$five")
  limits_seg="${DIM}5h${RESET} ${color}$(printf "%.0f%%" "$five")${RESET}"
fi
if [ -n "$week" ]; then
  color=$(ctx_color "$week")
  week_part="${DIM}7d${RESET} ${color}$(printf "%.0f%%" "$week")${RESET}"
  [ -n "$limits_seg" ] && limits_seg="${limits_seg} ${week_part}" || limits_seg="$week_part"
fi

# jj revision info
jj_seg=""
if command -v jj &>/dev/null && [ -n "$cwd" ] && [ "$cwd" != "?" ]; then
  jj_info=$(cd "$cwd" && jj log -r @ --no-graph \
    --template 'change_id.short(8) ++ if(bookmarks, " [" ++ bookmarks.join(", ") ++ "]", if(description.first_line(), " \"" ++ description.first_line().substr(0, 30) ++ if(description.first_line().len() > 30, "…", "") ++ "\"", " (no description)"))' \
    2>/dev/null | head -1 | xargs)

  if [ -n "$jj_info" ]; then
    stat_line=$(cd "$cwd" && jj diff -r @ --stat 2>/dev/null | tail -1)
    ins=$(echo "$stat_line" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
    del=$(echo "$stat_line" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')
    delta=""
    [ -n "$ins" ] && [ "$ins" != "0" ] && delta="${GREEN}+${ins}${RESET}"
    [ -n "$del" ] && [ "$del" != "0" ] && delta="${delta} ${RED}-${del}${RESET}"
    [ -n "$delta" ] && delta=" ${delta}"

    jj_seg=" ${SEP} ${CYAN}@${RESET} ${BRIGHT_CYAN}${jj_info}${RESET}${delta}"
  fi
fi

model_seg="${BOLD}◆${RESET} ${model}"
out="${model_seg} ${SEP} ${ctx_seg} ${SEP} ${tokens}"
[ -n "$limits_seg" ] && out="${out} ${SEP} ${limits_seg}"
out="${out}${jj_seg}"

printf "%s" "$out"
