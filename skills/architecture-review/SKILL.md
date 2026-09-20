---
name: architecture-review
description: |
  Review a codebase for structural defects, propose ranked restructurings that
  make it simpler, and apply the ones the user approves.
argument-hint: '[part of the codebase, commit, or concern to focus on]'
allowed-tools:
  - Bash(wc *)
  - Bash(jj new *)
  - Bash(jj describe *)
  - Bash(jj commit *)
---

Review the codebase for structural defects, propose ranked restructurings that
make it simpler to understand and maintain, and apply the ones the user
approves.

# Target

Arguments: $ARGUMENTS

Review the part of the codebase, the commit, or the concern named in the
arguments. With no arguments, review the whole codebase. The current commit is
not the default, because structural defects span files no single change touches.

# Principles

- Propose only restructurings that remove concepts, files, parameters, branches,
  or code. When a proposal adds an abstraction, state what it deletes in
  exchange. Drop a restructuring that only moves the complexity elsewhere
- Ask of each concept whether the program needs it before asking where it must
  be. Before proposing to delete a concept, find the case it exists for. If the
  case is real, propose a simpler form of the concept instead of its removal
- Treat the documented design as the intent. `CLAUDE.md`, the glossary, and the
  docs state decisions and their reasons. Drop a finding that contradicts a
  documented decision, unless the decision's reason no longer holds. Then report
  the finding with the decision and why its reason fails. Report code that fails
  to meet a documented decision as a finding
- Follow the patterns the project already uses. When the codebase solves a
  problem one way in one place (a handler table, a base class, a factory),
  propose that shape for the same problem elsewhere before inventing a new one
- If the project has no published release, break compatibility. Delete migration
  code, fallbacks, aliases, and the old path when the new one replaces it. If it
  has a published release, flag each change to public API in the report and let
  the user decide whether to shim it

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Workflow

1. Read `CLAUDE.md`, the glossary if one exists, and any architecture or
   layering docs. Write a list of the documented layering, dependency direction,
   and design decisions, each with its reason. Every reviewer checks findings
   against this list
2. Map the target: the packages and modules, their sizes (`wc -l`), the
   composition root, and the import graph between packages. Note every
   dependency edge that points against the documented direction
3. Review in parallel with read-only subagents (see "Fanning out"). For a target
   small enough to read in one pass, review it yourself
4. Verify every finding you will propose against the code: open the cited lines
   and confirm the claim. Drop each finding the code contradicts, and each that
   "Testing a finding" rules out
5. Synthesize the findings into one ranked report (see "The proposal"). Merge
   findings that share a root cause into one proposal. Stop and wait for the
   user to approve proposals before changing code
6. Apply the approved proposals (see "Applying")
7. Report what changed (see "After applying")

# Lenses

Apply each lens to the whole program, each package or crate, each module, and
each function or type.

Several lenses list a skill. The reviewer, you or a subagent, loads each listed
skill for its review criteria only and follows this skill's workflow instead of
the loaded skill's. Ignore a loaded skill's instructions to edit code, commit,
or report.

- Concepts the program doesn't need: a type, state, mode, or mechanism that
  exists for a case that never happens, or that two other concepts already cover
- Speculative generality: an abstract base class or interface with one
  implementation, type parameters instantiated once, injection points no caller
  uses, configuration nobody sets. Propose the specific form, unless a second
  real instance exists
- Dead code, found by tracing data flow: fields written and never read, returns
  every caller ignores, exports used only by tests. Static tools that match by
  name miss these
- Mixed altitude: a unit that uses the vocabulary of two levels of abstraction,
  or a file whose order is not top-down. Load `/stratify`
- Leaky boundaries and bad coupling: interfaces stated in implementation terms,
  callers that reach through a module, a lower layer importing a higher one,
  generic code branching on a specific case. Load `/encapsulate`
- Duplication and multiple sources of truth: one decision implemented twice, one
  value stored or derived in two places, two paths into the same state (such as
  a bulk import that creates invoices without the validation the form runs).
  Load `/reuse`
- Illegal states: booleans and optionals that encode a state machine,
  combinations that the code must guard against. Load `/outlaw-states`
- Misplaced code: logic in the composition root or a command entry point that
  must be in a domain module, high-level policy mixed into a low-level layer,
  such as a discount rule inside the database client. Load `/relocate`
- Names: jargon and imported metaphors, one concept under several names, a
  variable whose name differs from its type's (`client: InvoiceStore`). Load
  `/concretize`, and `/reconcile-language` when the vocabulary is unsettled
- Repeated switches: the same switch over a kind in several files, such as a
  switch over payment method in checkout, refunds, and receipts, which a table
  of one handler per kind would replace
- Parallel structures that differ for no reason: sibling adapters or handlers
  whose naming and shape diverge. Load `/homogenize`
- Conventions callers must remember: a cache every writer must invalidate, a
  permission check every route must repeat. Propose returning what changed, or a
  type that makes the check unnecessary
- Extra passes: a loop that reruns a deterministic step until its output stops
  changing, a second loop over the orders to sum what the first loop could have
  summed, a date formatted to a string and parsed back
- Hand-rolled code: code that the standard library, an installed dependency, or
  the framework already provides, and code that works against the language's or
  the framework's idioms
- Structural optionality: two allowed forms for one thing (a plugin as one file
  or a directory, a timeout in seconds or as a duration string) where one form
  would do

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Fanning out

Split the target into slices along package boundaries, sized so one subagent can
read its slice in full. Give each subagent:

- The repository path and the list of documented decisions from step 1, with the
  rule from "Principles" for findings that contradict one
- Its slice, plus the callers it must read to judge boundaries
- The lenses, and the skills to load for them
- The instruction to stay read-only: no edits, no `jj` or `git` commands
- The output: each finding with the fields a structural proposal has in "The
  proposal", and what in the slice should be left alone

Then run cross-cutting reviewers over the whole target, each checking one
concern: dependency direction between packages, multiple sources of truth across
packages, or duplication across packages. Slice reviewers miss these because
each reads only its own slice.

# Testing a finding

Drop a finding when:

- The complexity is essential: the domain, format, or protocol has the shape the
  code has
- It is a deliberate boundary: an adapter or shim that is complex so its callers
  stay simple
- The restructuring needs a vague name, a new flag, or an abstraction over two
  things that change for different reasons, or it makes the code more indirect
  or grows the exposed API

Keep but demote a finding when the defect is real and the cost of the change
outweighs the gain. Say what fixing it would cost.

# Reporting

## The proposal

Open with one paragraph on the overall shape: where the codebase is sound and
where the problems concentrate.

Then, in this order:

1. Bugs found during the review, each with its evidence, its fix, and the
   structural proposal that would prevent that class of bug
2. Structural proposals, ranked by complexity removed against risk. Complexity
   removed counts the concepts deleted and the drop in the number of places that
   adding the next feature would change. When the project has a skill or
   checklist for adding a new kind of thing (a payment provider, an export
   type), count the files it lists. Group proposals that share one shape (such
   as "every report module imports the web layer for one date helper"). For
   each, give the evidence with `file:line`, why it matters, the restructuring,
   what it deletes, and the trade-off. Mark a proposal as needing design
   approval when it leaves choices open for the user, such as new module
   boundaries or names
3. Smaller items, one line each
4. Leave alone: what the reviewers agreed is right and a restructuring must not
   touch

Number every item so the user can approve by number.

## After applying

Report each applied proposal and what it deleted, the commits, the checks run
and their results, every deviation from the approved wording with its reason,
and any proposal or part of one abandoned during implementation, with why.

# Applying

- Do every approved item, including the small ones. Don't defer an approved item
  without asking
- For a proposal marked as needing design approval, present the design first and
  wait
- Make one commit per proposal, or per group when the proposals touch the same
  code, with `jj commit <paths>`. Describe each with `/jj-describe`
- When subagents apply proposals in parallel, give each a disjoint set of files,
  and say in each prompt which files other agents are editing. Run a sequential
  pass at the end to reconcile changes that cross slices
- Before each commit, run the project's format, lint, and typecheck, and the
  tests for the files touched. Fix failures before committing
- Preserve behavior and wire formats unless the proposal says otherwise. Add a
  regression test for each bug fixed
- When the code shows a proposal won't work, stop work on it and keep the part
  that works
- In the last commit, reconcile `CLAUDE.md`, the docs, and the project's skills
  with the new structure. Load `/reconcile-claude-md` and `/reconcile-skills`
