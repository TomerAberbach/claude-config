---
name: distill-transcripts
description: |
  Distill a project's transcripts into proposals for eliminating repetitive
  work: skills, scripts, hooks, rules, or fixes to whatever causes the
  repetition.
argument-hint: '[project directory to read, or a focus area]'
allowed-tools:
  - Bash(sh *extract-prompts.sh *)
  - Bash(sort *)
  - Bash(cut *)
  - Bash(wc *)
---

Read the project's transcripts for work the user does repeatedly, then propose a
remedy for each pattern nothing already covers. Propose only. Build nothing
unless the user picks it.

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
2. Enumerate what already covers repetitive work here, before reading a single
   prompt, so you judge candidates against a fixed list. See "Enumerating
   existing coverage"
3. Read every extracted prompt. Call none irrelevant before you read it
4. Cluster the prompts by what the user wanted, not by the words used. "Rewrite
   this so each function stays at one level" and "this reads bottom-up, fix it"
   are one task. For each cluster, keep every prompt in it, the sessions it
   spans, and two or three verbatim examples showing the range. See "What counts
   as repetitive work"
5. Judge each cluster against the enumeration. See "Judging existing coverage"
6. For each surviving candidate, choose the remedy. See "Choosing a remedy",
   then "Choosing a level" for the remedies that have one
7. Report as in "Reporting". Offer to build the ones the user picks: run
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

Open with the scope: which project or projects, how many prompts, how many
sessions, the date range, and how many existing skills, rules, hooks, and
scripts you checked against.

Then the proposals, most prompts first, each as:

- The work, in one imperative line, and its counts:
  `N prompts across M sessions`
- Two or three verbatim prompts, quoted and trimmed to their point
- Coverage: uncovered, or adjacent with what it neighbors and the boundary
- Remedy: which kind, or which existing thing to amend, and one line on what it
  would do
- Level: user or project, with the reason in a clause, or where the script or
  fix goes

Then the borderline list, one line each. Close with:

- Candidates dropped as covered, one line each with what covers them
- What the sample misses: prompts you could not classify, and other projects'
  transcripts you did not read
