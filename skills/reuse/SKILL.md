---
name: reuse
description:
  Find opportunities for code reuse in the changed code, both against existing
  code and within the change itself, without creating bad coupling or contrived
  abstractions.
disable-model-invocation: true
---

Find opportunities for code reuse in the changed code, both against existing
code and within the change itself, without creating bad coupling or contrived
abstractions.

# Recently changed files

```!
jj show --git
```

$ARGUMENTS

# Principles

- Duplication is only a problem when the copies must change together. Two pieces
  of code that look alike but encode different decisions are coincidentally
  similar; merging them couples unrelated change reasons
- The best reuse adds no new code: call something that already exists in the
  codebase, the standard library, or an installed dependency
- A little duplication is cheaper than the wrong abstraction. When in doubt,
  leave the copies

# Workflow

1. For each changed function or code chunk, search for code that already does
   the job, in order of preference:
   1. The standard library of the language
   2. Dependencies already installed (check the manifest, e.g. `package.json`;
      don't propose new dependencies)
   3. Utilities and helpers elsewhere in the codebase
   4. Other code in the same module
2. Compare the added chunks against each other: a change often introduces the
   same logic twice in different files, and neither copy existed before, so
   searching existing code won't surface it
3. For each duplication found in steps 1 and 2, decide whether to reuse or
   extract, using the tests below
4. If nothing passes the tests, say so and stop; don't invent findings
5. Report each opportunity (see "Reporting"). Don't apply changes unless the
   arguments or a follow-up message ask for it

# Tests for a reuse opportunity

Flag an opportunity only when it passes all of these:

1. Same reason to change: if a requirement shifts, every call site must want the
   new behavior. If one caller might need to diverge, it's coincidental
   similarity
2. Honest name: the shared code has a precise name describing one job. If the
   best available name is vague (`helper`, `util`, `process`, `handleData`), the
   abstraction is contrived
3. No parameter switches: the shared code needs no boolean flags, mode enums, or
   callbacks whose only purpose is to make callers behave differently. Each such
   knob is the duplication smuggled back in
4. Dependencies point downward: callers depend on something at a lower level of
   abstraction. Never make a general module import from a specific feature, and
   never couple two unrelated features to share a few lines
5. Worth its weight: the shared code saves more than it costs. Extracting three
   trivial lines into a new shared module fails this; replacing a hand-rolled
   deep-clone with an existing utility passes

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Reporting

For each opportunity, one paragraph: the duplicated or reimplemented logic (file
path and line range), the call sites it covers, what to reuse or extract
instead, and the test that came closest to failing, with why it still passes.
Order by impact, largest first.
