---
name: outlaw-states
description:
  Remove illegal states from data structures by redesigning their types so the
  illegal states cannot be represented at all.
argument-hint: '[file, type, or data structure to tighten]'
---

Redesign the target's data structures so illegal states are unrepresentable:
replace representations that permit invalid combinations with types whose every
value is valid, so construction rejects what scattered runtime checks used to
catch.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Tighten the target named in the arguments if given; otherwise the code changed
in the current commit shown above; if there are no arguments and the commit has
no changes, ask the user what to tighten and stop.

# Principles

- An illegal state is a value the type admits but the program must never hold.
  The signals are runtime guards against "impossible" cases: validation that
  rejects combinations of fields, assertions that a variant's fields are
  populated, comments like "only set when status is X", errors thrown from
  branches that "can't happen".
- Make the type fit the states, not the states fit the type. Count the states
  the type can represent and the states the program has. When the first exceeds
  the second, reshape the type until they match; don't add more guards.
- Parse, don't validate. Check raw input once at the boundary and convert it
  into a type that carries the proof, so code past the boundary needs no
  re-checking. A function that inspects data and returns a boolean forces every
  later reader to trust the check happened; a function that returns a narrower
  type makes the check impossible to skip.
- Push the change to where the data is created. Constructing an illegal value
  should fail at the construction site, at compile time where the language
  allows, not at a runtime check downstream. If a tightening merely moves a
  guard from one downstream function to another, the state is still
  representable; the fix is a type or constructor no illegal value can pass
  through.
- Preserve behavior for valid states. This is a representation change: every
  valid state maps to exactly one value of the new type, and the program's
  observable behavior on valid inputs is unchanged. Unlike a pure refactor, the
  type's shape changes on purpose; callers that construct or match on the type
  must change, and that is the point.
- Weigh the tightening against the churn. A type touched by half the codebase
  costs more to reshape than a guard costs to keep. Tighten when the illegal
  state has caused or plausibly will cause a bug, or when the guards outweigh
  the churn; leave a benign representation alone.

These principles double as the test for a tightening: make one only when it
deletes a guard or an impossible branch AND every valid state survives. They
aren't exhaustive; reason from first principles when none fits cleanly.

# Workflow

1. Read the whole target once, plus the tests that cover it, to learn which
   states are valid. Note how to run those tests and the typecheck.
2. Inventory the illegal states: for each data structure, list the values its
   type admits that the program treats as impossible (see "Spotting illegal
   states"). The guards, assertions, and comments show where those states are.
3. If every type already admits only valid states, tell the user and stop. Don't
   manufacture redesigns.
4. For each illegal state, pick a technique that removes it (see "Techniques")
   and apply the principles as tests. Skip tightenings that fail the churn test;
   report those as deliberate keeps.
5. Apply the tightenings one at a time. For each: reshape the type, update every
   construction and use site, and delete the guards and impossible branches the
   new type obsoletes. Run the typecheck and the covering tests before moving
   on. If the language has no static types, encode the constraint in the
   constructor (smart constructor, factory) so illegal construction fails at the
   one place values are created, and verify with the tests.
6. At each boundary that receives raw data (parsers, deserializers, request
   handlers), keep one validation step and change it to return the tightened
   type. Everything past the boundary should need no re-checking; if a
   downstream guard survives, the type isn't tight yet.
7. Report what changed: each illegal state removed, the type reshaping that
   removed it, the guards and branches deleted, and how you verified valid
   behavior held.

# Spotting illegal states

- A boolean flag plus data meaningful only when the flag is set:
  `{ loading: boolean, data?: T, error?: E }` admits `loading` with `data`, or
  `data` with `error`, states the UI never intends.
- Multiple optional fields with a dependency between them: "if `endDate` is set,
  `startDate` must be too", enforced only by a comment or a validator.
- A string or number standing in for a closed set: a `status: string` that is
  always one of four words, a `port: number` that must be 1 to 65535.
- Two collections that must stay in sync: parallel arrays, a map plus a list of
  its keys, a count stored beside the items it counts.
- A collection that must not be empty, guarded by
  `if (items.length === 0) throw` at each use.
- The same validation repeated downstream of a boundary: every function
  re-checks that the email is well-formed because the type `string` carries no
  proof the first check ran.
- A state machine encoded as independent booleans (`isConnecting`,
  `isConnected`, `isClosed`) where most combinations are meaningless.

# Techniques

- Sum types for mutually exclusive states: replace flag-plus-optional-fields
  with a discriminated union, one variant per real state, each carrying only the
  fields that exist in that state.
  `{ state: 'loading' } | { state: 'ok', data: T } | { state: 'error', error: E }`.
- Closed sets for values typed as `string`: a union of literals or an enum
  instead of `string`; the compiler now exhausts the cases `switch` used to
  guard.
- Types that carry proof of validation: a branded or wrapped type
  (`ValidatedEmail`, `PositiveInt`) with its raw constructor private and a smart
  constructor that checks once and returns the tightened type or an error.
  Possession of the value is proof the check ran; no valid-looking-but-wrong
  value can be built elsewhere.
- Structures that make sync automatic: replace parallel arrays with one array of
  pairs; derive the count from the collection instead of storing it; replace the
  map-plus-key-list with the map alone.
- Non-empty by construction: a type that separates the first element from the
  rest (`{ head: T, rest: T[] }`) or a `NonEmptyArray` wrapper built only by a
  checked factory, so "empty" cannot reach code that assumes otherwise.
- Required-together fields grouped into one optional object: if `startDate` and
  `endDate` come and go together, make one optional `range: { start, end }`
  instead of two optional dates.

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Fixing mistakes

- The typecheck reveals a construction site you can't make valid: the program
  does pass through the "illegal" state, so it was a real state you missed. Add
  a variant for it rather than asserting the value into a variant it doesn't
  fit, or revert the tightening if the state is a short-lived intermediate not
  worth modeling.
- A valid state no longer round-trips (serialization, database rows, API
  payloads changed shape): the representation is also used outside the code you
  reshaped. Convert at the boundary between the stored shape and the tightened
  type instead of changing the wire format, unless the user asks for a
  migration.
- The tightened type spread flags or type parameters through untouched code: the
  churn test failed in practice. Revert and report it as a deliberate keep.
