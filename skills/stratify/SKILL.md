---
name: stratify
description:
  Refactor code so each function, class, and module sits at a single level of
  abstraction and reads top-down as a narrative.
arguments: target
disable-model-invocation: true
---

Refactor the target code so each function, class, and module sits at a single
level of abstraction and reads top-down as a narrative: high-level intent on
top, the mechanism that serves it extracted below.

Target: $target

# Principles

- One altitude per unit. A unit (a function's body, a class's public methods, a
  module's exported surface) should speak in one vocabulary: either the domain
  ("charge the card, email the receipt") or a single layer of mechanism
  ("advance the cursor, read the varint"), not both. Mechanism sitting amid
  domain steps is the signal to extract: pull a chunk out when it runs a level
  below the vocabulary around it, so the surrounding unit stays in one register.
- Reading a unit descends one level at a time. From its first line it reads as a
  list of named steps; each step's "how" lives one level down. A reader
  following the high-level narrative shouldn't need a chunk's internals to
  understand the step; the name carries the "what", the body holds the "how".
- A name replaces a paragraph, or the boundary is wrong. A well-named helper
  lets the reader skip the detail until they want it. The chunk must do one
  nameable job with a precise name: the domain step or the mechanism. If the
  best name is vague (`helper`, `process`, `handleData`, `doStuff`), the cut is
  wrong; find a different one.
- Narrative, not maximal decomposition. Extraction that adds an indirection
  without hiding detail the reader can skip makes things worse; the detail
  hidden must outweigh the indirection added. Pulling a dense fifteen-line
  mechanism out of an orchestrator passes; extracting one trivial line read in
  one place fails. A wall of one-line helpers each called once is its own
  readability failure; a unit that already reads as a single-altitude narrative
  is done, however long.
- Preserve behavior and the public surface. This is refactoring: a pure move,
  rename, and regroup, not redesign and not bug-fixing. If you find a bug while
  mapping altitudes, report it; don't silently fix it. Never change what callers
  outside the target see: extracted collaborators stay private behind the
  original methods, and a new module is re-exported from the old surface so
  importers don't move.

These principles double as the test for an extraction: make a cut only when it
clears all five. They aren't exhaustive; reason from first principles when none
fits cleanly.

# Workflow

1. Identify the target:
   - A file, module, or function named in the target
   - Otherwise, the code most recently under discussion in the conversation
   - If neither exists, ask the user what to refactor and stop
2. Read the whole target once, plus the tests that cover it, to learn the
   behavior you must preserve. Note how to run those tests.
3. For each function, class, and module, map its parts to their altitude (see
   "Spotting altitude mixing"): statements within a function, methods within a
   class, exports within a module. A unit is mixed when domain-level parts sit
   beside lower-level mechanism.
4. If every unit already reads top-down at a single altitude, tell the user and
   stop. Don't manufacture extractions.
5. For each mixed unit, decide what to extract by applying the principles as
   tests. Skip cuts that don't clear all five.
6. Apply the extractions one at a time. After each, run the covering tests or a
   typecheck to confirm behavior is unchanged before moving on. If neither
   exists, tell the user verification is by inspection only, then make smaller,
   more conservative extractions and re-read each diff to confirm the move was
   pure.
7. Once the unit is settled, order the definitions top-down where the language
   and the file's conventions allow: callers above the callees they invoke, so
   the file itself reads as a descent.
8. Report what changed: the units refactored, the helpers extracted with their
   names, and how you verified behavior held.

# Spotting altitude mixing

- A function that both orchestrates ("validate, then save, then notify") and
  inlines the mechanism of one step (the bit-twiddling, the index math, the
  string parsing) inside the same body.
- Section comments that announce a phase: `// build the request`,
  `// now validate`. Each marks a chunk whose name should replace the comment.
- Deep nesting where the inner blocks handle plumbing the outer logic shouldn't
  have to see.
- A long unit where some lines speak the domain and others speak the runtime,
  forcing the reader to change registers line to line.
- A class whose public methods straddle altitudes: some express the domain role
  the class plays, others expose mechanism a collaborator should own. The
  low-altitude cluster is a class waiting to be extracted.
- A module whose top-level entry point can't be understood without reading every
  helper, because the helpers aren't named for what they do, or whose exports
  mix the feature it offers with utilities that belong one layer down.

# Applying an extraction

- Match the extraction to the unit. From a function, pull a chunk into a new
  helper named for what it accomplishes. From a class, gather the low-altitude
  methods and the state they touch into a private collaborator the class
  delegates to, keeping the class's public methods unchanged. From a module,
  move the lower-layer code into their own module the surface imports, and
  re-export anything that was public so importers don't move. In each case the
  original site becomes one named step among its peers.
- Pass only what the chunk needs and return only what the caller uses; don't
  reach through shared mutable state to fake a clean boundary.
- Place the helper near its caller and below it, following the file's existing
  layout. Keep extracted helpers colocated, not scattered across the file.
- Match the surrounding code's conventions: naming, parameter style, and idiom
  of the file you're in, even where they differ from your own defaults.
- When the same extracted logic already exists elsewhere, this is reuse, not a
  new helper. Follow `../reuse/SKILL.md` to decide whether to call the existing
  code instead.

# Fixing mistakes

- A test fails or the typecheck breaks after an extraction: the move wasn't
  pure. Recheck the captured variables and the return value; revert that one
  extraction and redo it if you can't spot the gap.
- An extraction made the code harder to follow: the indirection it added
  outweighs the detail it hid. Inline it back and leave the chunk where it was.
- You renamed something a caller outside the target depends on: search for other
  references before keeping a rename, and restore the original public name.
