---
name: jj-describe
description: |
  Write a description for the current `jj` commit.
argument-hint: '[extra guidance on the description]'
allowed-tools:
  - Bash(jj describe *)
  - Bash(jj op log *)
  - Bash(jj undo *)
---

Write a description for the current `jj` commit.

# Current commit

```!
jj show --git
```

# Recent descriptions

```!
jj log -r 'ancestors(@-, 10)' --no-graph -T 'description'
```

Arguments: $ARGUMENTS

# Principles

- Explain why the change was made, because the diff already shows what changed
- Summary line in the imperative mood, under 72 characters, no trailing period
- A body only when the summary leaves something unexplained: the motivation, a
  rejected alternative, or a consequence a reader would miss. Wrap it at 72
  columns, separated from the summary by a blank line
- Match the recent descriptions above: prefix style, capitalization, and detail.
  Lacking a consistent convention, use Conventional Commits:
  `<type>(<optional scope>): <summary>`, with a type of `feat`, `fix`, `docs`,
  `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`, and
  a `!` before the colon for a breaking change
- Describe the commit's own change, not the stack it sits in

# Workflow

1. Read the diff above. If the commit is empty, tell the user and stop
2. Treat any existing description as the author's intent: keep what it states
   and extend it to cover the rest of the diff, unless the arguments say to
   replace it
3. Work out why the change was made. Read the surrounding code when the diff
   alone doesn't explain it. Prefer the arguments over your own inference
4. Set the description with `jj describe -m '<summary>' -m '<body>'`, passing a
   second `-m` only for a body. Each `-m` becomes its own paragraph
5. Show the result with `jj log -r @ --no-graph -T 'description'`

# Fixing mistakes

Rerunning `jj describe` is safe: it replaces the whole description. To recover
the previous one, find the describe operation with `jj op log` and revert it
with `jj undo <operation>`.
