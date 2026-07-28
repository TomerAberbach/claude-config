---
name: relocate
description: |
  Move code that ended up in the wrong place to where it belongs: the right
  file, module, layer, or package.
argument-hint: '[file, module, or function to relocate]'
---

Find code that sits in the wrong place and move it to the file, module, layer,
or package that owns the concept it serves.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Relocate the target named in the arguments if given. Otherwise relocate the code
changed in the current commit shown above. If there are no arguments and the
commit has no changes, ask the user what to relocate and stop.

# Principles

- Code belongs where a reader would look for it. The concept it serves
  determines its home, not the order it was written in or the file that happened
  to be open
- Neighbors change together. Code belongs beside code that changes for the same
  reason and serves the same callers. When a unit's reason to change has drifted
  from its file's, it is in the wrong file
- Dependencies point toward the stable and the general. Specific features may
  depend on general code; the general must never import the specific. A move
  that corrects a backwards import is right; a move that creates one is wrong
- One home per concept. A concept split across two places has no owner, and the
  next change lands in whichever half its author found first
- Relocation is not redesign. Only the address changes. The body stays byte for
  byte the same. If the code must be rewritten to fit its new home, that is a
  separate change. Report it rather than folding it in
- A move must be worth making. Move when the misplacement misleads readers or
  forces a bad dependency. Leave code that is merely not where you would have
  put it

These principles double as the test for a move: make one only when it clears
every principle. They aren't exhaustive. Reason from first principles when none
fits cleanly.

# Workflow

1. Read the target and enough of its surroundings to know what each file,
   module, and package is for. Note how to run the tests covering the target
2. For each unit in the target (a file, a class, a function, a type, a constant,
   a test), name in one sentence the concept it serves and who calls it. Then
   name the module that owns that concept
3. Compare each unit's current home to that owner (see "Spotting a
   misplacement"). A unit is misplaced when the two differ
4. If everything already sits with its concept, tell the user and stop. Don't
   shuffle code to produce a diff
5. For each misplacement, pick the destination and test it against the
   principles. Skip moves that don't clear every one. If no module owns the
   concept, create one rather than settling for the least-bad neighbor
6. Apply the moves one at a time (see "Applying a move"). After each, run the
   covering tests or a typecheck before moving on. If neither exists, tell the
   user verification is by inspection only, then move smaller units and re-read
   each diff to confirm the move was pure
7. Report what changed: each unit moved, where it came from and where it went,
   why the new home owns it, the references updated, and how you verified

# Spotting a misplacement

- An import that points the wrong way: a general module importing from a
  feature, a lower layer importing a caller's types, two siblings importing each
  other. The imported code, not the import, is what's misplaced
- A helper defined inside one feature and imported by another. It belongs in
  whatever both already depend on, or in the feature that owns it
- Something placed in `utils`, `helpers`, `common`, or `lib` that only one
  module imports and that uses that module's vocabulary. Push it down into that
  module
- Logic inline in an entry point (a CLI command, a route handler, a UI
  component, a migration script) that has nothing to do with entry-point
  concerns and would be tested on its own if it lived elsewhere
- A type, constant, or default declared beside its first consumer when it
  belongs to another module's interface, so every later consumer imports it
  across a boundary or copies it
- A file whose contents no longer match its name, or a name that only repeats
  its directory (`orders/orderUtils.ts`)
- A test in a file that doesn't cover the code under test, or a test left behind
  in the old suite after its subject moved
- Code in a shared package that adds dependencies to that package for the sake
  of one consumer
- A new sibling file added when an existing file already owns the concept

These aren't exhaustive. Reason from first principles when none fits cleanly.

A unit can be in the right file yet at the wrong level of abstraction. That is
`/stratify`'s job. Load it when the fix is extraction rather than relocation.

# Applying a move

- Move the whole unit and everything that exists only to serve it: its private
  helpers, types, constants, tests, and the comments explaining it. Half a move
  leaves the concept split across two places
- Move the content unchanged, so the diff reads as a rename. Any edit the new
  home needs comes after, as its own step
- Update every reference in the same step. Search the repo for the old path and
  the old name, including tests, mocks, barrel files, config, and docs. Leave no
  re-export shim behind, except for a published API whose consumers you can't
  edit. Say so in the report when you leave one
- Keep names unless the new home makes part of the name redundant:
  `formatOrderDate` moving into `orders/` becomes `formatDate`. A name that
  still reads well where it landed stays
- Match the destination's conventions: file layout, naming, export style, and
  import ordering, even where they differ from the source's
- When no module owns the concept, create one at the layer the principles imply,
  then move into it. Don't create a package for a single function unless the
  layering requires it
- When the destination already holds the same code, that's reuse, not
  relocation: load `/reuse` to decide whether to merge them
- When you can't name the concept a unit serves, its boundary is wrong, not just
  its address. Load `/encapsulate` before moving it

# Fixing mistakes

- A test fails or the typecheck breaks after a move: a reference was missed or
  the content changed during the move. Diff the moved code against the original.
  If it isn't identical, restore it and re-apply
- A circular import appeared: the destination is at the wrong layer. Revert, and
  either move the unit down to something both sides already depend on or invert
  the dependency
- The diff no longer reads as a rename: content changed along the way. Split it
  into a pure move and a follow-up edit
- The new home is a grab bag with no single concept: it's a `utils` by another
  name. Revert and pick a module you can describe in one sentence
- References remain to a name that no longer exists: search for it as a string,
  not only as a symbol, to catch dynamic imports, config, and documentation
