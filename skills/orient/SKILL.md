---
name: orient
description: |
  Produce a reading order for a codebase: a map of how data flows through it, a
  breadth-first pass over structure and interfaces, then optional depth-first
  dives per module.
argument-hint: '[repo, subtree, or commit to produce a reading order for]'
allowed-tools: Bash(jj file list *)
---

Produce a reading order for the target codebase: a map of how data flows through
it, a breadth-first pass that teaches its structure and interfaces, then
optional depth-first dives per module, each one skippable. Read the code. Don't
change anything.

# Target

```!
jj file list | head -n 500
```

```!
jj show --stat
```

Arguments: $ARGUMENTS

Produce the reading order for the target named in the arguments if given.
Otherwise produce it for the whole repository listed above. If the arguments
name the current commit, scope the order to the files it changes plus whatever a
reader must read first to understand them.

The listing above is truncated: a starting point, not the enumeration.

# Principles

- The order teaches, it doesn't inventory. Every file earns its place by what it
  lets the reader understand next. A file nothing depends on and nothing
  explains doesn't belong in the order
- Breadth before depth, at every level. A level's pass covers the shape of the
  whole thing: what the parts are, how they interact, where control enters. Only
  then does the reader descend into one part
- Each dive is skippable. After the breadth-first pass, a reader who skips every
  dive should still understand what the system does and how its pieces fit.
  Nothing in a later group may be a prerequisite for an earlier one
- Interfaces before implementations. Type definitions, schemas, public exports,
  route tables, and config define the vocabulary. The code that implements them
  assumes it
- Recurse only where complexity requires it. A module of three files gets a flat
  list. A module with its own submodules gets its own breadth-first pass, then
  its own dives
- Say why, briefly. One line per file or group: what the reader gets from it.
  Without that the order is unusable for deciding what to skip

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Workflow

1. Enumerate the files in scope mechanically (`jj file list`, a glob, the
   commit's changed files), not from memory. Exclude generated output, vendored
   code, lockfiles, and snapshots, and note that you did
2. Read the orientation files first: README, CLAUDE.md, package manifests,
   workspace config, build config, and the entry points they name. These
   determine the top-level decomposition. Don't guess it from directory names
   alone
3. Partition the files into modules (see "Finding module boundaries"). Each
   in-scope file goes to one module, to the breadth-first pass, or to the
   leftovers
4. Build the breadth-first pass: the smallest set of files that conveys the
   whole system's structure, flow, and interfaces. See "What goes in a breadth
   pass". Order it entry point first, then the interfaces control flows through
5. Trace the data flow (see "Tracing the data flow") so the reader has a map of
   what moves through the system before reading the files that move it
6. Order the modules by dependence, foundations first, so a dive never assumes a
   later one
7. For each module, build its own reading order. If small, list its files in
   dependency order. If it has submodules or more than ten files, recurse: a
   breadth pass for that module, then its own skippable dives
8. Verify the order (see "Verifying the order") and fix what fails
9. Report as in "Reporting". Don't edit any files

# Finding module boundaries

A module is a set of files that is conceptually one unit. Evidence, strongest
first:

- A directory with its own index, entry point, or public exports, and a name
  that describes it
- A cluster whose files import each other freely but reach the rest of the
  codebase through a few named symbols
- A package or workspace member with its own manifest
- Files sharing a naming prefix or suffix that marks a role (`*.route.ts`,
  `handlers/`)
- A test file's scope: what one test file covers is one unit
- A coherent part of the domain vocabulary, even when the files are scattered

Directory layout is evidence, not proof. When imports contradict the tree, trust
the imports and say so in the report. Files that fit no module go to the
leftovers.

# What goes in a breadth pass

At the top level, and again inside any module big enough to recurse:

- The entry point or points: `main`, the server bootstrap, the CLI root, the
  exported index
- The public interface: exported types, schemas, protocol or API definitions,
  the database schema
- The wiring that shows how parts connect: dependency injection setup, the
  router, the plugin registry, the module index
- One representative end-to-end path through the system, named as a path: the
  request that comes in, the handler it reaches, the store it writes
- Configuration and build files only where they change how the code is read

Keep it small. Ten to twenty files at the top level of a large repo, enough to
answer "what are the pieces and how do they interact", not "how does any one
piece work". Prefer citing a specific region of a long file over the whole file.

# Tracing the data flow

The reading order lists what to read. The data flow lists what moves: where data
enters, what shape it takes at each hop, what transforms it, and where it comes
to rest or leaves.

- Start at the boundaries: request bodies, CLI arguments, file reads, message
  queues, environment. Name the input as the codebase does
- Follow each input to its resting place: a database write, a response, a file,
  a rendered view. Stop there
- Name the shape at each hop, using the codebase's own type or table names, and
  the file that does the transforming
- Mark where the shape changes and where the same data is merely passed through.
  A hop that changes nothing can be collapsed
- Distinguish data flow from control flow. Which function calls which is control
  flow, and the breadth pass already covers it. Trace what the calls pass
- Cover the flows that explain the system, not every flow. One primary path,
  plus the ones that differ in kind: a background job, a write path against a
  read path, a stream against a request
- Name what crosses a trust or process boundary: unvalidated input, data that
  leaves for another service, secrets. Where validation or encoding happens is
  part of the shape

# Verifying the order

- Follow the order as a reader would: at each file, is every concept it uses
  either defined earlier or deferrable to a later dive? Move what fails
- Cut every dive and check the breadth pass still stands on its own
- Check every hop in the data flow names a real file and a real shape, both
  read, not inferred from a name. A hop you couldn't follow is a gap to report,
  not one to guess at
- Check the leftovers: each is either a file the reader can skip (say why) or a
  boundary you missed
- Circular dependencies between modules mean no order can be foundations-first.
  Pick the direction that reads better, and say which edge the reader must
  accept before its definition

# Reporting

A nested list, groups labelled so any dive can be skipped:

- Open with the shape: how many files in scope, how many modules, and what you
  excluded
- **Data flow**: each traced flow as a chain of hops, `shape` → `shape`, with
  the file that performs each transform. One line of prose per flow saying what
  it accomplishes. Use a fenced `mermaid` `flowchart` instead when a flow
  branches, merges, or fans out enough that a chain misrepresents it. Put this
  before Pass 1: it is the map the file list is read against
- **Pass 1, structure and interfaces**: the breadth-first files in order, each
  with a one-line reason. Line or symbol ranges where a whole file is too much
- **Dive: `<module>`** for each module, in dependency order. Head each with one
  sentence on what the module does and what the reader gets from it, so they can
  skip it on that sentence alone. Then its files in order, each with a one-line
  reason. Nest a sub-pass and sub-dives inside a module that needed recursion
- Close with the leftovers, the circular dependencies you had to break, and
  anything you could not place
