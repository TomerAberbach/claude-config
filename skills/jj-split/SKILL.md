---
name: jj-split
description: |
  Split the current `jj` commit into multiple focused, self-contained, easy to
  review commits.
argument-hint: '[extra guidance on how to split]'
allowed-tools:
  - Bash(jj show *)
  - Bash(jj log *)
  - Bash(jj diff *)
  - Bash(jj describe *)
  - Bash(jj split *)
  - Bash(jj new *)
  - Bash(jj edit *)
  - Bash(jj describe *)
  - Bash(jj squash *)
---

Split the current `jj` commit into multiple focused, self-contained, easy to
review commits.

# Current commit

```!
jj show --git
```

$ARGUMENTS

# Principles

- One concern per commit: e.g. bug fix, feature, refactor, or config change
- Each commit passes all checks: format, lint, typecheck, build, test
- Tests go in the same commit as the code they test
- Never mix refactors with behavioral changes
- Prefer thin vertical slices, one complete feature end-to-end, over horizontal
  layers
- No orphaned code: use every added API, abstraction, or stub within the same
  commit. Don't split so small that a commit contains dead code

# Workflow

1. Read the diff above. If the commit is already small and self-contained, tell
   the user and stop
2. Identify logical groupings and order them from most foundational to most
   dependent. When a boundary is ambiguous, keep changes together
3. Infer verification commands from project signals (e.g. `package.json`,
   `Makefile`, CI config). If there are none, ask the user
4. Present the plan as a numbered list:
   - Commit N: `<imperative-mood description>: <file or hunk list>`
   - One sentence justifying each split boundary
   - The verification commands you will run after each split
   - Ask for confirmation
5. Split each commit except the last. After each split, edit the newly created
   parent commit (`jj edit @-`) and run the verification commands
6. Give every resulting commit a description with `jj describe`
7. After all splits, run `jj log -r 'ancestors(@, <commit count>)'` and show the
   resulting stack

# How to split

## By file

Use `jj split` with file patterns to put specific files in the first commit:

```sh
jj split -m "<first commit description>" -- <files for first commit>
```

The remaining files stay in the second commit.

## By hunk

When a single file contains changes that belong in different commits, edit the
file directly:

1. Edit the file to contain only the changes for the first commit (remove hunks
   that belong later)
2. Run `jj new` to start the next commit
3. Re-edit the file to restore the hunks removed in step 1
4. Verify with `jj log -r '@-::@'` and `jj diff -r @-`

# Fixing mistakes

Use these when verification fails because changes are in the wrong commit.

## Move files between child and parent commits

```sh
# Move from child to parent
jj squash --from @+ --into @ -- <files>

# Move from parent to child
jj squash --from @ --into @+ -- <files>
```

## Move hunks between commits

When the boundary falls inside a file, edit the file directly:

1. While on the commit that should lose the hunk, remove it from the file
2. Switch to the other commit and restore the hunk there
3. Verify both commits
