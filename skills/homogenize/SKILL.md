---
name: homogenize
description:
  Make a set of things (code, prose, config, docs) consistent along a dimension
  the user names, by picking a canonical form and conforming every member to it.
argument-hint: '<the dimension of consistency> [files or text to homogenize]'
---

Make a set of things consistent along one dimension: identify the set's members,
pick a canonical form for the dimension the user named, and conform every member
to it without changing what any member means or does.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

The arguments name the dimension of consistency (e.g. "error message wording",
"test naming", "heading capitalization") and optionally the files or text that
form the set. Operate on the set named in the arguments if given; otherwise the
things changed in the current commit shown above. If the dimension is missing,
infer it from the conversation. If you still cannot determine the set or the
dimension, ask the user and stop.

# Principles

- One dimension per pass. Conform only the dimension the user named. Other
  inconsistencies you notice go in the report, not in the edits; mixing
  dimensions makes the change hard to review and easy to get wrong.
- Consistency must preserve meaning. Rewording a message, renaming a test, or
  reordering keys must not change behavior or a claim. If conforming a member
  would change its meaning, it is a deliberate exception: leave it and say why.
- The canonical form comes from the set, not from taste (see "Choosing the
  canonical form"). Invent a new form only when no existing member is fit to
  copy, and say so in the report.
- Membership is a judgment call for borderline things. A thing that
  superficially resembles the set but serves a different purpose is not a
  member; conforming it couples unrelated things. When unsure, leave it out and
  note it.

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Workflow

1. Determine the dimension and the set from the arguments and conversation (see
   "Target"). State both in one sentence before editing, so the user can catch a
   wrong guess early.
2. List every member with its current form. Search beyond the obvious files: a
   set defined by purpose (all error messages, all CLI flags, all section
   headings) is usually scattered.
3. Pick the canonical form (see "Choosing the canonical form"). If two forms are
   equally defensible and the choice matters, ask the user which to use and
   stop; otherwise pick and note the choice in the report.
4. If every member already matches, tell the user and stop. Don't manufacture
   edits.
5. Conform each member to the canonical form:
   - In prose, comments, and config, edit the wording or structure in place.
   - For identifiers, treat each change as a behavior-preserving rename: update
     every reference, and never break a name that callers outside the set depend
     on.
6. If any code changed, run the covering tests or a typecheck to confirm
   behavior is unchanged. Pure prose edits need no test run.
7. Report: the dimension and canonical form, each member changed (from what to
   what), members left as deliberate exceptions and why, borderline non-members
   you excluded, and other inconsistent dimensions you noticed but did not
   touch.

# Choosing the canonical form

- Count first. When most members already agree, the majority form is canonical
  unless the user said otherwise; conforming the few to the many is the
  smallest, safest change.
- On a tie, prefer the form that is clearest on its own terms: the one a
  newcomer would understand without seeing the others.
- A prescribed form wins even when it is the minority: follow the user's
  guidance over the majority and report the scale of the resulting change.
- If the best form needs vocabulary the project doesn't use consistently, stop
  and suggest `/ubiquitize-language` instead of forking the project's terms.

# Fixing mistakes

- A test or typecheck breaks after a rename: you missed a reference or the name
  is used outside the set. Find the other references or restore the original
  name.
- A conformed member now says something false or does something different: the
  member was a borderline non-member or an exception. Revert it and move it to
  the exceptions in the report.
