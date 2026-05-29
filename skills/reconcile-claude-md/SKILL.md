---
name: reconcile-claude-md
description:
  Update the project's CLAUDE.md to match its current structure and conventions.
disable-model-invocation: true
---

Update the project's CLAUDE.md to match its current structure and conventions.

# Goals

- Delete guidance about structure or conventions that no longer exist
- Update outdated commands, paths, and names
- Add guidance for conventions Claude can't derive from the code

# Current CLAUDE.md

```!
cat CLAUDE.md
```

$ARGUMENTS

# Workflow

1. If the project has no CLAUDE.md, suggest `/init` and stop
2. Break CLAUDE.md into individual claims: commands, paths, tool choices,
   workflow rules, style rules. One claim per bullet
3. Verify each claim against the repo:
   - Commands: confirm the script, target, or binary exists (package.json
     scripts, Makefile targets, lockfiles). Don't run mutating commands
   - Paths and names: confirm the files and directories exist
   - Conventions: sample a few recent source files and check they follow it
4. Reconcile the project structure section (see "Project structure section")
5. Explore for undocumented conventions worth recording: tool choices not
   implied by config files, commands with non-obvious flags, layout rules,
   gotchas a newcomer would trip on
6. Edit CLAUDE.md: delete stale claims, fix outdated ones, add missing guidance.
   Match the file's existing structure and tone, and admit only facts that pass
   "What belongs"
7. Report each deletion, fix, and addition with the evidence for it. Flag claims
   you couldn't verify instead of guessing

# Project structure section

CLAUDE.md should have a shallow `tree`-style code block of the layout:

- Annotate each entry with a one-line purpose comment. The comments are the
  value; an unannotated listing is derivable and doesn't belong
- Keep it shallow: top-level directories and load-bearing files. Collapse
  directories with uniform contents into one glob entry (e.g. `**/<name>/`)
  annotated with the pattern its contents follow
- Add the section if missing. Prune entries that no longer exist, rename moved
  ones, and add new load-bearing entries

# What belongs

CLAUDE.md earns its tokens only with facts Claude can't cheaply derive:

- Keep: the annotated structure tree, tool and command choices among
  alternatives, conventions not enforced by tooling, invisible constraints
  (deploy quirks, protected files, ordering requirements)
- Cut: unannotated file listings, anything a config file already states, lint
  rules the linter enforces, standard tool usage

These aren't exhaustive. Reason from first principles when none fits cleanly.
