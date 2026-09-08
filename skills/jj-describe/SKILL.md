---
name: jj-describe
description: |
  Write a description for the current `jj` commit.
argument-hint: '[extra guidance on the description]'
allowed-tools:
  - Bash(jj describe *)
  - Bash(jj diff *)
  - Bash(jj log *)
  - Bash(jj op log *)
  - Bash(jj undo *)
  - Agent
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

# Recent descriptions for the changed files

```!
jj log -r "latest(::@- & files($(jj diff -r @ --name-only | sed 's/.*/\"&\"/' | paste -sd'|' -)), 10)" --no-graph -T 'description.first_line() ++ "\n"'
```

Arguments: $ARGUMENTS

# Principles

- Explain why the change was made, because the diff already shows what changed
- Write the summary line so it completes the sentence "If applied, this commit
  will ...": 50 characters preferred and 72 at most, no trailing period. Name
  the fix rather than the problem it fixes. Avoid a filename or a generic phrase
  such as "fix bug", "refactor", or "cleanups"
- Match the prefix style, capitalization, and detail of the previous commits to
  the same files, falling back to the recent descriptions above where those
  commits disagree. Without a consistent convention, write `<topic>: <summary>`,
  where the topic is the module, directory, or command the change touches
- Add a body only when the summary leaves something unexplained: the status quo
  the change corrects, the motivation, how the change works, a rejected
  alternative, a known limitation, or a consequence a reader would miss. Wrap it
  at 72 columns, separated from the summary by a blank line
- State the status quo in the present tense and without "Currently", because a
  description is read against the code before the change: "the parser stops at
  the first error"
- Explain how the change works only where the diff leaves it unclear, in plain
  words and at the level of the feature rather than the code
- Mention a rejected alternative only when you tried it, rather than only
  considered it, and a reader would ask why you didn't take it
- Back a claim about performance or size with the measurements before and after
  the change
- Leave out what the diff shows, such as which files and functions changed and
  that the tests were updated
- Leave out how the commit came about, such as what was tried first, what it was
  rebased onto, and what happened in the session that wrote it
- Describe the commit's own change, not the stack around it
- Keep the description readable on its own. Summarize an issue or a linked page
  rather than pointing at it, and name another commit by its change ID and its
  summary line rather than the ID alone

# Workflow

1. Read the diff above. If the commit is empty, tell the user and stop
2. Treat any existing description as the author's intent: keep what it states
   and extend it to cover the rest of the diff, unless the arguments ask for a
   replacement
3. Read the descriptions for the changed files above to see which convention
   previous commits to these files followed
4. Work out why the change was made. Read the surrounding code when the diff
   alone doesn't explain it. Prefer the arguments over your own inference
5. Run `/humanize` on the planned description in a subagent, passing the text
   inline and asking for the revision back. Give the subagent nothing else, so
   it reads the draft cold
6. Take the revision, restoring anything it dropped and rewriting a summary line
   it pushed past 72 characters. Set the description with
   `jj describe -m '<summary>' -m '<body>'`, passing a second `-m` only for a
   body. Each `-m` becomes its own paragraph
7. Show the result with `jj log -r @ --no-graph -T 'description'`

# Fixing mistakes

Rerunning `jj describe` replaces the whole description. To recover the previous
one, find the describe operation with `jj op log` and revert it with
`jj undo <operation>`.
