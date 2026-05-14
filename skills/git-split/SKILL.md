---
name: git-split
description:
  Split the current `git` commit into multiple focused, self-contained, easy to
  review commits.
user-invocable: true
allowed-tools:
  - Bash(git show *)
  - Bash(git log *)
  - Bash(git reset HEAD~1)
  - Bash(git add *)
  - Bash(git commit *)
  - Bash(git stash)
  - Bash(git stash pop)
---

Split the current `git` commit into multiple focused, self-contained, easy to
review commits.

# Current commit

```!
git show
```

# Principles

- One concern per commit: e.g. bug fix, feature, refactor, or config change
- Each commit passes all checks: format, lint, typecheck, build, test
- Tests travel with the code they test
- Refactors are never mixed with behavioral changes
- Prefer thin vertical slices, one complete feature end-to-end, over horizontal
  layers
- No orphaned code: every added API, abstraction, or stub must be used within
  the same commit. Don't split so small that dead code is introduced

# Workflow

1. Read the diff above. If the commit is already small and self-contained, tell
   the user and stop
2. Identify logical groupings and order them from most foundational to most
   dependent. When a boundary is ambiguous, keep changes together
3. Infer verification commands from project signals (e.g. `package.json`,
   `Makefile`, CI config). If no signals are found, ask the user
4. Present the plan as a numbered list:
   - Commit N: `<imperative-mood description>: <file or hunk list>`
   - One sentence justifying each split boundary
   - The verification commands you will run after each split
   - Ask for confirmation before proceeding
5. Run `git reset HEAD~1` so all changes return to the working tree
6. Stage and commit each group in order, running verification commands after
   each:
   ```sh
   git stash
   <verification commands>
   git stash pop
   ```
7. After all splits, run `git log --oneline -<commit count>` and show the
   resulting stack

# How to split

## By file

Stage specific files for the first commit, then commit:

```sh
git add <files for first commit>
git commit -m "<first commit description>"
```

## By hunk

When a single file contains changes that belong in different commits, use file
manipulation:

1. Edit the file to contain **only** the changes for the first commit (remove
   hunks that belong later)
2. Stage and commit it
3. Re-edit the file to restore the removed hunks before the next commit
