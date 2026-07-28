---
name: allay
description: |
  Settle an unnamed unease about a piece of code by naming the design defect
  behind it or ruling the unease unfounded, then handing off to the skill that
  fixes it.
argument-hint: '<what feels wrong, and where>'
---

Settle the stated unease about the target code: name the design defect behind
it, or rule the unease unfounded and say what the code is doing instead. Explain
and report. Don't fix.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Examine the target named in the arguments. With no arguments, examine the code
changed in the current commit shown above. If the commit has no changes either,
ask the user what feels wrong and stop.

# Principles

- The unease ends when it's explained, not when it's soothed. Escalating counts:
  "founded, and worse than you thought, here are the two consequences you
  haven't hit yet" settles the question as surely as finding nothing wrong.
  Never reach for the reassuring reading
- The unease is evidence, not a verdict. It says a reader stumbled somewhere. It
  doesn't say the code is wrong. Treat the user's words as a symptom to explain,
  not a conclusion to justify
- Name the defect or clear the code. A diagnosis that ends in "it could be
  cleaner" is no diagnosis. Either name a defect and cite the lines that exhibit
  it, or call the unease unfounded and explain what the code is doing that felt
  wrong but isn't
- Unfounded is a real outcome, and so is "real but not worth fixing". Essential
  complexity, an unfamiliar idiom, and a boundary that is deliberately ugly so
  its neighbors stay clean all provoke the same feeling as a defect. Say so
  plainly when that's the answer
- The symptom and the defect are often in different places. A parameter feels
  wrong because a caller upstream can't answer a question, or because the type
  admits a state the callee must then handle. Read the call sites before ruling
- Explain the feeling, not only the code. The user asked why they feel this way.
  Connect the named defect back to the specific thing they noticed, so the
  diagnosis reads as recognition rather than assertion
- Name the primary defect. Several names may fit. Say which one, if fixed, would
  remove the rest, and treat the others as consequences

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Workflow

1. Restate the unease in one sentence: what the user pointed at, and what the
   feeling is about it
2. Read the target, every call site, and the tests that cover it. Enumerate the
   call sites mechanically (`rg` for the symbol), not from memory. For each,
   note what the caller knows, what it passes, and what it does with the result.
   Awkward tests localize a defect faster than the code does
3. Match the symptom against the checklist (see "Naming the defect"). For each
   candidate that fits, write the concrete evidence: the lines, the call sites,
   the states, the duplication
4. Test each candidate against "Testing a candidate"
5. Rule, one of three: founded, with one primary defect named; founded but not
   worth fixing, with the cost that outweighs it; or unfounded, with what the
   code is doing
6. Report as in "Reporting", including the handoff. Don't change any code unless
   the arguments or a follow-up ask for it

# Naming the defect

- Mixed altitude. One unit speaks in two vocabularies: domain steps beside the
  mechanism that serves them, or an orchestrator that inlines the parsing.
  Symptom: each line reads fine, but no single sentence describes what the
  function does. Handoff: `/stratify`
- Leaked implementation. The interface is stated in its own terms rather than
  its callers': inner types in the signature, a required call order, a caller
  that revalidates or reassembles what the module returned. Symptom: "why does
  the caller have to know that?" Handoff: `/encapsulate`
- Illegal state. The type admits combinations the program must never hold, so
  guards, assertions, and impossible branches multiply downstream. Symptom: a
  parameter typed `unknown` or `string` that the body immediately narrows, or a
  case that "can't happen". Handoff: `/outlaw-states`
- Contrived coupling. Two things are joined that have separate reasons to
  change: a shared helper with a boolean that picks the caller's branch, a
  general module importing a specific feature, an abstraction extracted from two
  coincidental similarities. Symptom: changing one caller means proving the
  other is unaffected. Handoff: `/reuse` for the duplication side,
  `/encapsulate` for the direction side
- False symmetry. Two parameters, branches, or cases are presented as peers but
  aren't: a function taking both a raw value and its derived form, an `else`
  that handles a different kind of thing than the `if`, a pair of functions
  named alike that make different guarantees. Symptom: one argument is
  redundant, or the two sides can disagree and nothing says which wins. Handoff:
  `/outlaw-states` when the fix is making the disagreement unrepresentable,
  `/stratify` when one side belongs a level down
- Duplicated logic. The same decision is encoded in two places that must change
  together. Handoff: `/reuse`
- Misplaced code. The unit is correct but lives in the wrong file, module, or
  layer, so its neighbors don't explain it. Handoff: `/relocate`
- Wrong or unsettled name. The code says one thing and does another, or one
  concept goes by three names. Handoff: `/rename-concept` for a single term,
  `/ubiquitize-language` when the vocabulary itself is unsettled, `/concretize`
  when the name is jargon or an imported metaphor
- Speculative generality. Parameters, hooks, and indirection that exist for a
  caller that doesn't exist. Symptom: every call site passes the same value.
  Handoff: none. The fix is deleting it

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Testing a candidate

A candidate that matches none of these is founded. These four make it unfounded:

- Essential complexity. The problem has the shape the code has: the format is
  ugly, the protocol has four modes, the domain rule has five cases.
  Restructuring moves the mess. It doesn't remove it
- A deliberate boundary. The unit is an adapter, parser, shim, or compatibility
  layer, ugly so its callers aren't. Concentrated ugliness at a boundary is the
  design working
- The alternative is worse. Name the restructuring you'd propose and check it
  against the handoff skill's own tests. If the fix needs a vague name, a new
  flag, or an abstraction over two things that change for different reasons, the
  current code wins
- Unfamiliarity, not defect. The idiom is standard for the language, framework,
  or file, and reads as odd only from outside it

Two more change the verdict rather than clearing it:

- The churn outweighs the gain. The defect is real but small, and the type or
  signature is touched by half the codebase. Rule it founded but not worth
  fixing
- The defect is elsewhere. This unit is fine. The awkwardness belongs to a
  caller or to a type imposed on it. Rule on that site instead, and say the
  target moved

# Reporting

Open with the verdict in one sentence: the primary defect named, or why the
unease is unfounded. Then:

If founded, with or without a fix:

- What the user noticed, and the defect that explains it, connected explicitly
- The evidence: file paths and line ranges, the call sites, the states or
  duplication that demonstrate it
- The secondary defects, if any, and why they follow from the primary one
- The candidate you came closest to also naming, and why you didn't
- The handoff: which skill fixes it, and the target to run it on; or, when the
  churn outweighs the gain, what fixing it would cost. Stop there unless asked
  to continue

If unfounded:

- What the code is doing that produced the feeling
- The restructuring you considered and the test it fails
- Anything improvable that isn't what they noticed, marked as minor
