---
name: reconcile-claude-md
description: |
  Update the project's CLAUDE.md files to match its structure and conventions.
argument-hint: '[directory to focus on, or extra guidance]'
---

Update the project's CLAUDE.md files to match its structure and conventions.

# CLAUDE.md files

```!
find . -name CLAUDE.md -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/.jj/*' -exec wc -l {} +
```

Arguments: $ARGUMENTS

If the arguments name a directory, the scope is the CLAUDE.md files in that
directory and below it. Otherwise the scope is every file listed above. Treat
the rest of the arguments as extra guidance.

# Workflow

1. If `./CLAUDE.md` is missing, suggest `/init` and stop
2. Read every CLAUDE.md in scope. When the scope is a directory, also read the
   CLAUDE.md files of its ancestors, but edit only files in scope. Break each
   file into individual claims in your notes: commands, paths, tool choices,
   workflow rules, style rules
3. Verify each claim against the repo:
   - Commands: confirm the script, target, or binary exists (package.json
     scripts, Makefile targets, lockfiles). Don't run mutating commands
   - Paths and names: confirm the files and directories exist
   - Conventions: check that recently changed source files follow the convention
   - When a claim fails and the repo shows the current form of its subject, such
     as a renamed script or a moved path, fix the claim. Otherwise delete it
4. Delete each claim that fails "What belongs"
5. Move each remaining claim to the file that "Splitting by directory" selects.
   Plan any new subdirectory CLAUDE.md files and the claims that move into them
6. Reconcile each file's tree following "Project structure section"
7. Look for facts that pass "What belongs" and that no CLAUDE.md records yet.
   Check CI config, package scripts, config files, and recent commit
   descriptions for tool choices, non-obvious flags, layout rules, and gotchas
8. Edit the files. Match each existing file's structure and tone, and match a
   new file to its parent CLAUDE.md
9. Check for contradictions within each file and between a parent and a child.
   Resolve each one in favor of what the code does
10. Report each deletion, fix, move, and addition with the evidence for it.
    Report claims you couldn't verify and problems in ancestor files outside the
    scope

# What belongs

Every line of a CLAUDE.md costs context in every session that loads the file.
Long files lower adherence, because the rules that matter get lost among the
ones that don't. For each line, ask: would Claude make a mistake without it? If
not, delete it, even if it's correct. Apply this test to anything the lists
below don't cover.

- Keep:
  - Commands Claude can't guess, and tool choices among alternatives
  - Code style rules that differ from the language's defaults and that no linter
    or formatter enforces
  - When and how to run tests, beyond what the package scripts show
  - Repository etiquette: branch naming, commit and PR conventions
  - Architectural decisions the code doesn't explain
  - Environment quirks: required env vars, setup steps, deploy constraints
  - Invisible constraints: protected or generated files, ordering requirements
  - Gotchas a newcomer would trip on
- Cut:
  - Anything a single file read or command shows, such as the contents of code
    and config files
  - Standard language conventions and standard tool usage
  - Generic advice such as "write clean code"
  - File-by-file descriptions of the codebase
  - API documentation and tutorials. Link to them instead
  - Facts that change often enough to go stale between edits
  - Multi-step procedures that matter only for some tasks. Delete them and
    suggest a skill for each in the report

Write each kept instruction concretely enough to verify: "Run `pnpm test` before
committing", not "Test your changes". Don't add emphasis such as "IMPORTANT"
unless the user says Claude keeps breaking the rule.

# Splitting by directory

Claude Code loads the CLAUDE.md files in the working directory and its ancestors
at launch, and a subdirectory's CLAUDE.md once Claude reads or edits a file
there. A fact in a subdirectory's file costs context only in sessions that work
in that directory.

- A module is a directory with its own stack, commands, or conventions, such as
  a workspace package
- State each fact once, in the CLAUDE.md of the deepest module that contains
  everything the fact applies to. Put facts that apply across modules in the
  root. Delete copies in other files
- Move a section that concerns one module into that module's CLAUDE.md. A file
  over about 200 lines signals that it holds such sections
- Create a subdirectory CLAUDE.md only to hold at least one fact that passes
  "What belongs". A tree alone doesn't justify a new file

# Project structure section

Give a CLAUDE.md a `tree`-style code block of its directory when at least one
entry has a purpose its name doesn't make evident. Remove the tree when none
does.

- List directories and the files a reader needs to find: entry points, central
  config, files with unusual roles
- Annotate each entry with a one-line purpose. Delete an entry whose annotation
  restates its name
- Stop recursing where entries become implementation details, and at any
  directory that has its own CLAUDE.md. List that directory as one annotated
  entry
- Collapse directories with uniform contents into one glob entry (e.g.
  `**/<name>/`), annotated with the pattern their contents follow
- Delete entries that no longer exist, rename moved ones, and add new
  directories and important files
