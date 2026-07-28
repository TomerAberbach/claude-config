---
name: reconcile-skills
description: |
  Update a project's SKILL.md files to match the code they describe.
argument-hint: '[skill path or name, or extra guidance]'
---

Update a project's SKILL.md files to match the code they describe.

# Project skills

```!
find .claude/skills -name SKILL.md 2>/dev/null
```

Arguments: $ARGUMENTS

Reconcile the skills named in the arguments if given. Otherwise reconcile every
skill listed above, treating any arguments that name no skill as extra guidance.
If there are no arguments and the project has no skills, say so and stop.

# Goals

- Correct identifiers, paths, and commands that no longer match the code
- Delete steps for things that no longer exist
- Add steps for things a skill's procedure now misses

# Workflow

1. Read the skill in full, including its supporting files. A claim in a linked
   reference file drifts the same way as one in SKILL.md
2. Break it into individual claims, one per bullet, by the kinds in "Verifying
   claims"
3. Verify each claim against the code, as in "Verifying claims"
4. Trace the procedure end to end against the current code: walk the steps as if
   performing them, and note steps that are impossible, redundant, or missing
5. Edit the skill: fix wrong claims, delete dead steps, add missing ones. Keep
   its existing structure and tone, and hold additions to "What belongs"
6. Re-check the frontmatter: `name` matches the directory, the description still
   states what the skill does, and `allowed-tools` covers the commands the body
   runs and no more
7. Report each fix, deletion, and addition with the evidence for it. Flag claims
   you couldn't verify instead of guessing

# Verifying claims

- Identifiers: `grep` for the exact symbol. A near miss is the common failure:
  the skill says `categorize`, the code exports `categorizeEntry`. Check the
  spelling, the casing, and whether it's still exported
- Paths: confirm each file and directory exists. For globs, confirm they still
  match something
- Commands: confirm the script, target, or binary exists (package.json scripts,
  Makefile targets, lockfiles). Don't run mutating commands
- Registration sites: when the skill says "add an entry to X", open X and
  confirm the entries have the shape it describes
- Files-to-edit lists: trace an existing example of the thing the skill creates,
  from its definition through every place it's referenced, and compare that list
  against the skill's
- Behavior: read the code that implements it. Prose describing what a function,
  flag, or command does drifts silently, without any name to grep for

These aren't exhaustive. Reason from first principles when none fits cleanly.

# What belongs

A SKILL.md earns its tokens only with what Claude can't cheaply derive:

- Keep: the procedure and its ordering, the sites to touch and what to write at
  each, conventions the code doesn't announce, gotchas the obvious approach hits
- Cut: restatements of what the code plainly shows, steps the tooling does on
  its own, background the reader doesn't act on

Cross-reference sibling skills instead of restating them, and confirm any skill
a body references still exists.
