---
name: distill-transcripts
description: |
  Distill a project's transcripts into proposals for eliminating repetitive
  work: skills, scripts, hooks, rules, or fixes to whatever causes the
  repetition.
argument-hint: '[project directory to read, or a focus area]'
allowed-tools:
  - Bash(sh *extract-prompts.sh *)
  - Bash(sh *extract-actions.sh *)
  - Bash(sort *)
  - Bash(cut *)
  - Bash(wc *)
  - Bash(awk *)
  - Bash(uniq *)
  - Bash(grep *)
---

Read the project's transcripts for work that repeats, both the work the user
asks for and the work you do to satisfy it, then propose a remedy for each
pattern nothing already covers. Build nothing unless the user picks it.

Arguments: $ARGUMENTS

Read the transcripts of the project directory named in the arguments, or of the
current working directory if the arguments name none. If they ask for every
project (say, "all transcripts"), pass `--all`. If they name a focus area
instead (say, "testing" or "anything involving jj"), read the current project's
transcripts and keep only candidates in that area.

Load `/distill` first. It covers reducing a body of data to an artifact. This
skill supplies the data (transcripts), the question ("what work recurs?"), and
the artifact (a proposal list).

# Workflow

1. Run `extract-prompts.sh` (in this skill's directory) with the project
   directory as its argument, or `--all` for every project, writing its output
   to a file in the scratchpad directory. It prints one tab-separated `project`,
   `session id`, `timestamp`, `prompt` line per prompt, so `wc -l` gives the
   prompt count and `cut -f2 | sort -u` the session count. Pass
   `--max-chars 900` when the prompts are too long to read whole: it keeps each
   request and marks how much it cut. For a pasted log or a plan, that is all
   you need. Say in the report that you truncated. When the project has no
   transcripts it exits with an error. Report that and stop
2. Run `extract-actions.sh` (in this skill's directory) with the same argument,
   writing its output to a second file in the scratchpad directory. It prints
   one line per tool call, from the main thread and from the subagents a session
   spawned, with each tool's input reduced to a signature. Never read this file
   whole. See "Reading the action extract"
3. Enumerate what already covers repetitive work here, before reading a single
   prompt, so you judge candidates against a fixed list. See "Enumerating
   existing coverage"
4. Read every extracted prompt. Call none irrelevant before you read it
5. Cluster the prompts by what the user wanted, not by the words used. "Rewrite
   this so each function stays at one level" and "this reads bottom-up, fix it"
   are one task. For each cluster, keep every prompt in it, the sessions it
   spans, and two or three verbatim examples showing the range. See "What counts
   as repetitive work"
6. Cluster the actions. See "Reading the action extract"
7. Judge each cluster against the enumeration. See "Judging existing coverage"
8. For each surviving candidate, choose the remedy. See "Choosing a remedy",
   then "Choosing a level" for the remedies that have one
9. Report as in "Reporting". Offer to build the ones the user picks: run
   `/create-skill` for a skill, `/update-config` for a hook or a permission
   entry, and write a rule, script, or fix yourself

# Enumerating existing coverage

List what already exists, with a one-line summary of each:

- User skills: `~/.claude/skills/*/SKILL.md`
- Project skills: `<project>/.claude/skills/*/SKILL.md`
- Project commands: `<project>/.claude/commands/*.md`
- Plugin and built-in skills: the ones listed in this session's available-skills
  list
- Rules: `~/.claude/CLAUDE.md` and every `CLAUDE.md` in the project
- Hooks and permissions: the `hooks` and `permissions` keys of
  `~/.claude/settings.json` and the project's `.claude/settings.json`
- Scripts: the project's `package.json` scripts, `Makefile` targets, and
  whatever it keeps in `scripts/` or `bin/`

Count them by kind. The report opens with those counts. Read every summary, and
the body of anything close to a candidate. A name is not a procedure. Only the
body describes what it does.

# What counts as repetitive work

A cluster is a candidate when all of these hold:

- It holds three or more prompts spanning two or more sessions. One elaborate
  request is not a pattern; three plain ones are. Prompts repeated inside a
  single session count as one, because they are one task restated
- The user wanted the same outcome each time, whatever the phrasing
- The next occurrence is likely. A migration that finished last month will not
  come up again

A cluster that meets the last two but holds two prompts, one per session, is
borderline. Report it in a separate list of weaker candidates. Never drop it
silently.

The counts are the argument. A proposal without prompts behind it is your taste,
presented as evidence.

Corrections tell you more than plain requests do. A prompt that corrects what
you did ("no, split that into separate commits first") states a procedure the
user expects and you missed. Several such prompts across sessions form one
candidate.

Other kinds of clusters worth keeping:

- A preference restated in different projects or files
- A sequence the user walks you through step by step, the same way each time
- A command invoked repeatedly with the same hard-to-remember flags
- A prompt that is nothing but context you could have looked up yourself: a file
  path, a command's flags, a convention already written down
- Requests that already invoke a skill and then correct its output: evidence to
  amend that skill, not to add one

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Reading the action extract

A prompt cluster shows what the user asked for more than once. An action
cluster shows what the same request cost: the commands re-derived, the files
re-read, the calls that failed before they worked.

`extract-actions.sh` prints one tab-separated line per tool call:

| Column | Contents |
| --- | --- |
| 1 | project |
| 2 | session id |
| 3 | timestamp |
| 4 | tool name |
| 5 | signature: `Bash:jj diff`, `Edit:src/parse.py`, `Skill:humanize` |
| 6 | `err` when the call returned an error, empty otherwise |
| 7 | the skill that was running, empty when there was none |
| 8 | the subagent id, empty on the main thread |
| 9 | the input, truncated to 120 characters, or 900 for a subagent prompt |

Calls made inside a subagent are included, under the session that spawned them,
so session counts cover both. Column 8 separates them.

The extract runs to thousands of lines, so read counts before lines. Run the
queries below, read the top 30 rows of each, then read column 9 for the few
signatures that pass the threshold. The commands assume the extract is at `$A`.

Sessions spanned per signature. This is the primary table, because the
threshold counts sessions:

```sh
cut -f2,5 "$A" | sort -u | cut -f2 | sort | uniq -c | sort -rn | head -30
```

Failures per signature. A command that errors in session after session
indicates a broken default, a missing dependency, or a missing wrapper:

```sh
awk -F'\t' '$6 == "err"' "$A" | cut -f5 | sort | uniq -c | sort -rn | head -30
```

Files opened at the start of a session. A file read first in many sessions is
context to add to `CLAUDE.md` or to a document `CLAUDE.md` links:

```sh
awk -F'\t' '$4 == "Read" { if (++n[$2] <= 5) print $5 "\t" $2 }' "$A" |
  sort -u | cut -f1 | sort | uniq -c | sort -rn | head -30
```

Recurring sequences. Three signatures in a row, with consecutive repeats
collapsed, counted once per session. A sequence that recurs across sessions is
a procedure worth writing down:

```sh
awk -F'\t' '{ if ($2 != s) { s = $2; a = ""; b = ""; p = "" }
              if ($5 == p) next
              p = $5
              if (a != "" && b != "") print a " > " b " > " $5 "\t" $2
              a = b; b = $5 }' "$A" |
  sort -u | cut -f1 | sort | uniq -c | sort -rn | head -30
```

Failures per skill. A skill whose calls fail is a skill to amend, and column 7
contains it:

```sh
awk -F'\t' '$6 == "err" && $7 != ""' "$A" |
  cut -f5,7 | sort | uniq -c | sort -rn | head -30
```

To read a cluster once counting has selected it, filter to its signature:

```sh
awk -F'\t' '$5 == "Bash:uv run pytest"' "$A" | cut -f2,6,7,9 | head -40
```

Thresholds match the prompt side: three or more occurrences spanning two or
more sessions, with two occurrences borderline.

Subagent invocations are the exception to counting. A project produces tens of
them, not thousands, and each prompt states a task in full, so column 9 keeps
the prompt itself up to 900 characters. Read every one:

```sh
awk -F'\t' '$4 == "Agent"' "$A" | cut -f2,5,9
```

Cluster these the way you cluster the user's prompts, by what was asked. A
prompt written to a subagent three times across sessions is a strong skill
candidate, because you wrote the procedure out and threw it away each time. The
prompt is a first draft of the skill, and its repetitions show which parts
stayed fixed and which varied. The fixed parts become the skill's body and the
varying parts its arguments.

Discard the patterns that dominate every table and indicate nothing on their
own: search-then-substitute loops, and repeated Edits to one file. What counts
is a signature tied to this project: its own scripts, its test commands, its
files.

Where an action cluster restates a prompt cluster, merge it into that one as
evidence of the cost, and report it once. A cluster of failing `uv run ruff`
calls next to prompts asking to fix formatting is one candidate, not two.

An action cluster is weaker evidence than a prompt cluster, because the
user chose the prompts and you chose the actions. A command run many times may
be many tries at one badly specified job. Read column 7 before proposing
anything, and say in the report which clusters rest on actions alone.

# Judging existing coverage

For each candidate, one of three verdicts:

- **Covered**: something already covers this. Drop it, and name what covers it
  in the report so the user can see the judgment
- **Adjacent**: something covers work near it but not it. Name the boundary, and
  whether the fix is a new thing or an amendment to the existing one
- **Uncovered**: nothing covers it

A shared noun is not coverage. `/review` reading pull requests does not cover
writing an issue body. Compare procedures, not topics.

# Choosing a remedy

Take the first that fits:

- **Fix the cause.** The work recurs because something is broken or missing: a
  flaky test, a bad default, an error message that contains no fix, a step the
  build should do itself. Automating around it is the wrong remedy. Propose the
  repair
- **A rule** in `CLAUDE.md`, when the remedy is one line of standing guidance
  with no steps: a tool to prefer, a convention to keep
- **A script**, when the steps are deterministic and need no judgment. Name
  where it lives and what invokes it
- **A hook** in `settings.json`, when the work should happen every time some
  event occurs, without being asked. The harness runs hooks, but a rule cannot
  guarantee the work happens
- **A permission entry**, when the repetition is approval prompts rather than
  work. `/fewer-permission-prompts` already does this. Name it and move on
- **A skill**, when the task takes an ordered procedure with judgment calls
  worth writing down. Load `/create-skill` for the conventions
- **An agent definition** in `.claude/agents/`, when the repetition is a prompt
  written to a subagent: the same role, tools, and standing instructions each
  time, with only the target varying. The varying part becomes the prompt, and
  the rest becomes the definition

One cluster can warrant two remedies, such as a script plus the skill that
specifies when to run it. Say so rather than picking one.

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Choosing a level

Skills, rules, hooks, and permission entries live at user level or project
level. Scripts and fixes live in the project.

Project level when the work depends on something in this repository: its build
commands, directory layout, deploy steps, schema, or its own conventions.

User level when the work depends only on the user's tools and taste, and would
carry over unchanged to another repository. Transcripts from one project
undercount a user-level pattern because the same work in other projects is not
in this sample.

When both readings fit, propose user level with the project-specific parts
passed as arguments, and say so.

# Reporting

Open with the scope: which project or projects, how many prompts, how many tool
calls, how many sessions, the date range, and how many existing skills, rules,
hooks, and scripts you checked against.

Then the proposals from the prompts, most prompts first, each as:

- The work, in one imperative line, and its counts:
  `N prompts across M sessions`
- Two or three verbatim prompts, quoted and trimmed to their point
- Coverage: uncovered, or adjacent with what it neighbors and the boundary
- Remedy: which kind, or which existing thing to amend, and one line on what it
  would do
- Level: user or project, with the reason in a clause, or where the script or
  fix goes

Then, under a heading of its own, the proposals that rest on actions alone. The
user never asked for these, so each one opens with the evidence:

- The signature or sequence, and its counts:
  `N calls across M sessions`, plus `K failed` where any did
- Two or three lines from column 9, quoted
- What the pattern indicates, in one line: the missing context, the missing
  wrapper, the step that failed
- Coverage, remedy, and level, as above

Then the borderline list, one line each. Close with:

- Candidates dropped as covered, one line each with what covers them
- Action clusters merged into a prompt proposal, one line each
- What the sample misses: prompts you could not classify, tool calls whose
  signature was too coarse to cluster, the prompts written to subagents, which
  the prompt extract excludes because the user did not write them, and other
  projects' transcripts you did not read
