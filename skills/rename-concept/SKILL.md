---
name: rename-concept
description: |
  Rename a concept everywhere: propose candidate names with tradeoffs, let the
  user pick, then sweep the winner through identifiers, prose, docs, and skills.
argument-hint: '<the term to rename> [why, or a name you have in mind]'
---

Rename a concept across the whole project: learn what the term refers to,
propose several candidate names and defend them, get the user's pick, then apply
it everywhere the old term appears in code, prose, docs, the glossary, and
skills.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

The arguments name the term to rename and optionally a reason or a preferred
name. Rename the term named in the arguments if given. Otherwise rename a term
discussed in the conversation, or a term introduced by the changes in the
current commit shown above. If you cannot determine which term to rename, ask
the user and stop.

# Principles

- Rename the concept, not the string. The old term marks one idea. Find every
  place that idea is named, including spellings the first search misses
  (abbreviations, plurals, verb forms, adjectives) and skip places the same
  letters mean something else
- One concept per pass. If the search shows the term covers two distinct ideas,
  that is a split, not a rename: say so and get the user's decision on both
  names before editing
- The new name comes from the domain. Prefer the word a practitioner already
  uses for this thing over an invented or borrowed one (see `/concretize`)
- Check the name against prior art. A name that already means something else in
  the language, the ecosystem, or the codebase costs the reader a translation
- Candidates first, edits second. Never start renaming on a name you chose
  yourself. The user picks
- All or nothing. A half-applied rename leaves two words for one concept, worse
  than either name alone. Finish it or revert it

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Workflow

1. Establish what the term means. Read its definition and its main uses before
   proposing anything, because a rename chosen from the word alone names the
   wrong thing
2. Inventory every occurrence (see "Finding every occurrence"). Do this before
   proposing names: the count and spread show how big the change is, and the
   uses reveal whether the term covers one concept or two
3. If the term covers more than one concept, report the split and ask the user
   how to name each part before continuing
4. Propose three to five candidates (see "Proposing candidates"). Present them
   with `AskUserQuestion` and stop until the user picks. Accept a name they
   supply instead
5. Sweep the chosen name through every occurrence from step 2 (see "Applying the
   rename"). Work file by file and keep the inventory as your checklist
6. Re-run the searches from step 2. Every remaining hit is either a miss to fix
   or a place the letters mean something else. Note those in the report
7. Run the covering tests and a typecheck if any code changed
8. Report: the old term, the new name and why it won, counts by category (code
   identifiers, comments, prose, docs, glossary, skills, filenames), any public
   name deliberately kept, and any occurrence left alone because the letters
   meant something else

# Finding every occurrence

Search case-insensitively for the term and each of its forms, then widen:

- Identifier casings: `fooBar`, `FooBar`, `foo_bar`, `foo-bar`, `FOO_BAR`
- Morphological forms: plurals, `-ing`/`-ed` verb forms, adjectives, and the
  agent noun (`sweep`, `sweeps`, `sweeping`, `sweeper`, `swept`)
- Abbreviations and initialisms the codebase uses for it, including inside
  longer identifiers
- Filenames and directory names, test fixture names, and snapshot files
- Non-code text: comments, docstrings, README and docs, `glossary.md`,
  `CLAUDE.md`, `.claude/skills`, commit templates, CLI help text, error
  messages, and log strings
- Externally visible names: exported API, config keys, CLI flags, database
  columns, serialized field names, and public URLs

Group the hits by category as you go. The groups become the checklist for the
sweep and the shape of the report.

# Proposing candidates

Give each candidate one short paragraph:

- What it claims the thing is, in the domain's terms
- What it reads like at the call site or in a sentence: one line from the code
  or prose, rewritten
- Prior art: what the word already means in this language, ecosystem, or
  codebase, and whether that helps or collides. Search the codebase. Search the
  web when the term is likely to be a term of art
- What it costs: ambiguity it introduces, forms it lacks (a noun with no verb
  form), or length at the call sites where it appears most

Include the current name as a candidate when keeping it is defensible, and say
what would have to be true for that to be the right call. State your
recommendation and why.

# Applying the rename

- Code identifiers: treat each as a behavior-preserving rename and update every
  reference. For a name callers outside the project depend on, keep the old name
  as an alias and say so in the report rather than breaking them silently
- Comments and prose: rewrite the sentence, don't substitute the word. The old
  name shaped the phrasing around it, and a swap leaves an awkward or now-wrong
  sentence
- Files and directories: rename them too, and update every import, link, and
  path reference
- `glossary.md`: update the entry to the new term and list the old term under
  aliases to avoid. If there is no glossary and the project would benefit,
  suggest `/ubiquitize-language` rather than starting one mid-rename
- `.claude/skills` and `CLAUDE.md`: future sessions read these. Renaming
  everywhere else and leaving them stale reintroduces the old word
- Strings users see (CLI help, errors, docs): rename them, and call them out
  separately in the report
- Leave alone: quoted external material, historical commit messages, changelog
  entries about past releases, and vendored code. Note them in the report

# Fixing mistakes

- A test or typecheck breaks: a reference was missed, or the name collides with
  an existing one in scope. Fix the reference, or pick a non-colliding form and
  tell the user the chosen name needed adjusting
- A search for the old term still hits after the sweep: finish the sweep. Only
  homographs, quoted material, and history may remain
- The new name reads wrong once applied everywhere: stop and report it rather
  than half-reverting. The user picked the name and should decide whether to
  revert the whole sweep or continue
