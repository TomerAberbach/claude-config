---
name: jj-resolve-conflicts
description: Resolve conflicts in the current `jj` commit.
allowed-tools:
  - Bash(jj resolve *)
  - Bash(jj op log *)
  - Bash(jj undo *)
disable-model-invocation: true
---

Resolve conflicts in the current `jj` commit.

# Current status

```!
jj st
```

$ARGUMENTS

# Principles

- A resolution preserves the intent of both sides, not just their text. When
  both sides changed the same logic, produce code that does what each side set
  out to do
- Never delete a conflict marker without understanding what each side changed
  and why
- The resolved commit passes all checks: format, lint, typecheck, build, test

# Workflow

1. Read the status above. If there are no unresolved conflicts, tell the user
   and stop
2. List the conflicted files with `jj resolve --list`
3. Find where the conflict came from: `jj log -r '::@ & conflicts()'` shows the
   conflicted ancestry. Read the descriptions of the commits whose changes
   collided to understand each side's intent
4. For each conflicted file:
   - Read the file. Conflicts are materialized with markers (see "Reading
     conflict markers")
   - If one side should win wholesale, run `jj resolve --tool :ours <file>`
     (side #1) or `jj resolve --tool :theirs <file>` (side #2)
   - Otherwise edit the file to the semantic merge of both sides and remove the
     markers. When the markers alone are unclear, view each side's full file
     with `jj file show -r <revision> <file>`
5. Verify all conflicts are gone: `jj resolve --list` should report none and
   `jj st` should show no conflicted paths
6. Infer verification commands from project signals (e.g. `package.json`,
   `Makefile`, CI config) and run them. If no signals are found, ask the user
7. jj propagates the resolution to descendants of `@` automatically. Run
   `jj log -r 'conflicts()'`; any conflicts that remain are distinct and need
   their own resolution

# Reading conflict markers

jj materializes conflicts as a diff to apply, not two alternatives:

```
<<<<<<< Conflict 1 of 1
%%%%%%% Changes from base to side #1
-old line
+side #1's replacement
+++++++ Contents of side #2
side #2's version of the region
>>>>>>> Conflict 1 of 1 ends
```

- The `%%%%%%%` section is a diff: lines starting with `-` are the base, lines
  starting with `+` are side #1's edit, and unprefixed lines are context
- The `+++++++` section is side #2's full content for the region
- To resolve, apply side #1's diff to side #2's content, then reconcile whatever
  still disagrees

# Fixing mistakes

The next jj command snapshots a wrong resolution. To get the conflict back, find
the resolution's operation with `jj op log` and revert it with
`jj undo <operation>`. With no argument, `jj undo` reverts the most recent
operation.
