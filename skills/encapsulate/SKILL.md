---
name: encapsulate
description: |
  Find interface boundaries that leak their implementation and close the leaks,
  so each module hides one coherent decision behind an interface stated in its
  callers' terms.
argument-hint: '[file, module, or interface to examine]'
---

Find the interface boundaries in the target code that leak their implementation
and close the leaks, so each module hides one coherent decision behind an
interface stated in its callers' terms.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Work on the target named in the arguments if given. Otherwise work on the code
changed in the current commit shown above. If there are no arguments and the
commit has no changes, ask the user which boundary to examine and stop.

# Principles

- An interface states what a module guarantees, not how it works. Write its
  types, parameters, and errors in the caller's vocabulary. When a caller must
  account for the storage engine, the wire format, or the traversal order to use
  the interface, that detail is exposed and every caller now depends on it
- The module holds its own invariants, not the caller. Fixed call orders,
  remembered cleanup, revalidating what the module already validated, and
  reassembling a result from several accessors are all the module's job. Every
  caller duplicates each one, and it breaks silently when one caller omits it
- Ask the object for the answer, not for its parts. Reaching through a returned
  value to its internals binds the caller to a shape it doesn't control. Move
  the behavior to the data instead of pulling the data to the behavior
- One decision per module. A module is cohesive when its parts change for the
  same reason and serve the same callers. Parts that serve disjoint callers are
  two modules; two modules that always change together are one
- Dependencies point toward the stable and the general. Specific features may
  depend on general code; the general must never import the specific. When a
  lower layer needs something from above, the caller owns the interface and
  passes an implementation down
- Encapsulate without redesigning. This is refactoring: the boundary moves while
  observable behavior stays the same. Where a caller needs a capability the
  narrowed interface no longer offers, add it as a named operation. Don't expose
  the internals again. Report any bug you find rather than fixing it silently

These principles double as the test for a fix: apply one only when the corrected
boundary satisfies every principle. They aren't exhaustive. Reason from first
principles when none fits cleanly.

# Workflow

1. Read the whole target once, plus its callers and the tests that cover it, to
   learn the behavior you must preserve. Note how to run those tests
2. List the boundaries in the target: each module's exports, each class's public
   methods, each function's signature. For each, write in one sentence the
   decision it hides
3. Inspect each boundary for leaks (see "Spotting a leak"). A boundary leaks
   when a caller's correctness depends on something step 2 called hidden
4. If every boundary already hides its decision, tell the user and stop. Don't
   manufacture indirection
5. For each leak, choose a repair (see "Closing a leak") and test it against the
   principles. Skip repairs that don't clear every one
6. Apply the repairs one at a time, updating every caller in the same step.
   After each, run the covering tests or a typecheck to confirm behavior is
   unchanged before moving on. If neither exists, tell the user verification is
   by inspection only, then make smaller repairs and re-read each diff
7. After the last repair, re-read the corrected interfaces end to end and
   confirm each still reads as one coherent guarantee, not a set of unrelated
   additions
8. Report what changed: the boundaries you corrected, the leak each one had, the
   new interface, the callers updated, and how you verified behavior held

# Spotting a leak

- A test that must construct internals, stub private collaborators, or assert on
  intermediate state to exercise a public entry point. Awkward tests signal a
  leak
- Chained access through a returned value
  (`order.getCustomer().getAddress() .getZip()`), or a caller that loops over an
  internal collection to compute something the owner could return directly
- Types from an inner layer in a public signature: database rows, ORM entities,
  HTTP payloads, protocol buffers, framework request objects. The layer that
  produced them should translate at its boundary
- Errors in implementation terms crossing upward: SQL error codes, HTTP status
  numbers, driver exceptions. The caller now handles failures of the
  implementation the interface is supposed to hide
- Temporal coupling: the interface works only if operations run in one order, or
  a caller must pair a setup call with a teardown call. Docs or comments saying
  "call `init` first" mark the leak
- Boolean flags and mode enums that select which internal branch runs. They move
  the module's decision to the caller
- Callers that revalidate, renormalize, or reconstruct what the module returns,
  or that hold a rule the module also holds. The duplicated rule is the leak
- Bypassing the interface: globals, singletons, environment variables, or shared
  mutable state read on both sides instead of passed across
- Mutable structures handed out and retained, letting a caller change the
  module's state without going through the module
- Import direction violations: a general utility importing a feature, two
  sibling features importing each other, or a lower layer importing a caller's
  types for one constant
- Names in the interface drawn from the implementation (`cacheEntry`, `rowId`,
  `retryBuffer`) rather than the domain. When the guarantee is hard to name in
  the caller's words, the boundary is in the wrong place. Load
  `/ubiquitize-language` when the domain vocabulary itself is unsettled
- Exports used by no caller, or by exactly one caller that immediately wraps
  them. Either the interface is wider than the guarantee or the module has the
  wrong owner

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Closing a leak

- Move the behavior to the data. Replace a chain of accessors with one operation
  on the owner, named for the question being asked. The accessors it replaced
  can then become private or disappear
- Translate at the boundary. Define a type in the caller's vocabulary and
  convert the inner representation to it inside the module. Treat errors the
  same way: map implementation failures to a few named domain failures
- Replace flags with named operations. One entry point per behavior, each named
  for its outcome. Keep shared code private behind them
- Make the illegal call sequence unrepresentable rather than documented: hand
  back a value that exists only once setup succeeded, or wrap the pairing in a
  single operation that owns both halves. Load `/outlaw-states` when the fix is
  mainly a type redesign
- Invert the dependency. When a lower layer needs a decision from above, define
  the interface where the caller lives and pass an implementation in, so the
  general code depends on nothing specific
- Pass collaborators explicitly instead of reaching for globals, and hand out
  copies or read-only views instead of live internal structures
- Move the code, not just the call. When a caller holds logic belonging to the
  module, relocate it inside and delete the caller's copy; when a module holds
  logic only one caller uses, push it out
- Regroup for cohesion. Split a module whose parts serve disjoint callers; merge
  two that always change together. Load `/stratify` when the parts sit at
  different levels of abstraction, and `/reuse` when closing a leak reveals the
  same logic in two places
- Keep the change contained. Preserve the old names where they still fit, and
  re-export anything that moves so importers don't have to change

# Fixing mistakes

- A test fails or the typecheck breaks after a repair: the change altered
  behavior. Recheck what the old interface exposed that the new one doesn't,
  revert that one repair, and redo it more narrowly
- A caller needed something the narrowed interface no longer offers: add it as a
  named operation in the caller's vocabulary. Don't restore the raw accessor
- The new boundary turned into a pass-through layer that forwards calls
  unchanged: inline it back
- You split a module and the two halves now import each other: the split was in
  the wrong place. Merge them back and look for a different one
