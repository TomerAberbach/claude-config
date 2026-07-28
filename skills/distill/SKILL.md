---
name: distill
description: |
  Distill a body of data into a small artifact that keeps what matters: a
  research document, code that handles the data, a skill, a schema.
argument-hint: '<data to distill, and what artifact to produce>'
---

Distill the given body of data into an artifact far smaller than the data, one
that keeps what a reader or a program needs and drops the rest.

Arguments: $ARGUMENTS

Distill the data named in the arguments if given. Otherwise distill the data
already gathered in this conversation. If neither exists, ask the user what to
distill and stop.

# Principles

- The artifact answers a question. Name the question and who asks it before
  reading, or the result is a summary of everything and a distillate of nothing
- Distillation is loss. Choosing what to drop is the work; keeping it all is
  refusal to do the work
- Read every item, or state the sampling rule and its limits. A pattern found in
  the first ten items and asserted over a thousand is a guess
- Every claim in the artifact traces to something in the data. A claim that
  traces to nothing is your prior, not the data

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Workflow

1. Fix the target: what artifact, for whom, answering what question, and what it
   must let them do. See "Kinds of artifact". If the arguments name data but no
   artifact, propose one in a sentence and continue with it, saying so in the
   report
2. Enumerate the sources mechanically (`rg`, a glob, a manifest, a query, an API
   listing), not from memory. Record the count and what you excluded
3. Read a handful of items spanning the visible variety and write down a
   provisional shape: the dimensions along which items differ, the candidate
   categories, the fields that seem to matter. This orients the full pass, but
   doesn't replace it
4. Check every enumerated item against that shape. Record extractions in a
   working file under the scratchpad directory, each tagged with its source, so
   the artifact's claims stay traceable. Revise the shape when an item doesn't
   fit, then re-check the earlier items against the revision
5. Reduce: cluster the extractions, keep what recurs or changes the answer, drop
   the rest. See "Deciding what to keep"
6. Write the artifact at the smallest size that still answers the question, in
   the form its consumer needs, not as a list of everything you found
7. Verify it against the data (see "Verifying the distillate") and fix what
   fails
8. Report as in "Reporting"

# Kinds of artifact

The artifact determines what step 5 keeps:

- **Research document**: keep the findings, the evidence for each, and the
  disagreements between sources. Cite every claim
- **Code that handles the data**: keep the invariants the code may rely on and
  every shape it must tolerate. Here the outliers are the specification, because
  a format seen once still has to parse
- **Skill**: keep the procedure that worked and the judgment calls it turns on.
  Load `/create-skill` and follow its conventions
- **Schema or type**: keep the fields that are always present, always absent, or
  meaningfully optional, and the values each admits. Load `/outlaw-states` to
  keep the illegal shapes unrepresentable
- **Glossary**: load `/ubiquitize-language`, which already does this
- **Reference table or checklist**: keep one row per item and one column per
  question the consumer asks, and nothing else

# Deciding what to keep

Keep an item when:

- It recurs across sources that didn't copy each other. What appears once is an
  example at best
- Dropping it would change what the consumer does
- It's the only evidence for a claim the artifact makes
- It contradicts the pattern. An artifact that covers the average and hides the
  outliers fails where it's needed

Drop an item when it's an instance of a pattern already stated, when it's
context the consumer already has, or when it's true but bears on no decision.

When two sources disagree, neither one wins by default. Say what each holds and
what would settle it.

Watch for distilling your own output: once you've written a summary, later
passes confirm it rather than test it. Return to the sources.

# Verifying the distillate

- Round-trip: take items from the data at random, including ones you read late,
  and check that the artifact accounts for each. What it doesn't account for is
  either a gap or an exclusion you must state
- Trace every claim back to a tagged extraction. Cut the ones that don't trace
- For code and schemas, run the artifact against the real data, not a
  hand-written sample
- Ask what a reader would still get wrong knowing only the artifact
- Cut the largest section and ask whether the question is still answered. If it
  is, that section was padding

# Reporting

Deliver the artifact itself. Alongside it, say:

- What the artifact answers, and for whom
- How many sources you enumerated, how many you read, and what you excluded
- What you dropped and on what rule
- The residue: items that fit no pattern, and the disagreements left open
- How much you trust the enumeration

For a prose artifact, offer `/refine-context` and `/humanize`.
