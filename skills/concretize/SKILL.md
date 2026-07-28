---
name: concretize
description: |
  Replace jargon and imported metaphors in code and prose with concrete,
  domain-fitting terms a reader understands without translation.
argument-hint: '[file, identifier, or text to concretize]'
---

Replace jargon and imported metaphors in the target with concrete language: name
what is there, keep the terms the domain itself uses, and drop borrowed figures
of speech that the reader must translate back into meaning.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Concretize the target named in the arguments if given. Otherwise concretize the
code or prose changed in the current commit shown above. If there are no
arguments and the commit has no changes, ask the user what to concretize and
stop.

# Principles

- Name the thing, not a picture of it. A metaphor borrows a word from another
  domain to suggest meaning, and the reader must translate the picture back.
  Replace it with the plain term for the real thing: a "seam" is a boundary, a
  "load-bearing" call is a required one
- The domain's own words stay. A term the field uses in its specs and docs is
  not jargon to strip but the concrete name. "Socket", "stream", "deadlock",
  "idempotent", "quorum" belong even though each began as a metaphor. The test:
  would a practitioner write this word in a precise spec, or only in a blog
  post? Keep the first kind; cut the second
- Plain over fancy, even within the domain. When two correct terms fit, pick the
  one a newcomer to the team understands. Don't reach for the rarer or grander
  word when it adds no precision. A complex word is worth it only when it names
  a distinction the simpler word would lose
- Concretize, don't change meaning. Replacing a word must preserve the claim. If
  a metaphor makes a real distinction no plain term captures, keep it and say
  why rather than flatten the meaning

These principles are also the test for a replacement: make one only when the
result is more concrete AND says the same thing. They aren't exhaustive. Reason
from first principles when none fits cleanly.

# Workflow

1. Read the whole target once so you understand what it refers to before
   renaming anything. For code, note how to run its tests or typecheck
2. Find the candidates: jargon, imported metaphors, and needlessly fancy terms
   (see "What to replace"). Most words are fine
3. For each candidate, decide with the principles: is it the domain's own term
   (keep), or borrowed decoration (replace with the concrete name)? When unsure
   whether a word is domain vocabulary, check how the surrounding code and docs
   use it before cutting
4. If nothing should change, tell the user and stop. Don't manufacture edits
5. Apply the changes:
   - In prose and comments, edit the wording in place
   - For an identifier built on a metaphor, rename it. Treat this as a
     behavior-preserving rename: update every reference, and never change a name
     that callers outside the target depend on without restoring the public name
6. If you renamed any code, run the covering tests or a typecheck to confirm
   behavior is unchanged. Pure prose edits need no test run
7. Report what changed: each term replaced and the concrete word it became, and
   any metaphor you deliberately kept because it is the domain's term or makes a
   distinction no plain word does

# What to replace

- Imported metaphors that decorate rather than name. "seam", "load-bearing",
  "surface area", "blast radius", "north star", "first-class citizen", "the
  crux", "in the weeds", "table stakes", "move the needle", "boil the ocean",
  "heavy lift". Each names something concrete: a boundary, a required
  dependency, the exposed API, the scope of impact, the goal, fully supported,
  the key part
- Verbs used as filler. "leverage" is "use"; "surface" (as a verb) is "show" or
  "report"; "unpack" is "explain"
- Fancy words that add no precision. "utilize" is "use", "facilitate" is "help",
  "myriad" is "many". Prefer the short, common word unless the long one names a
  real distinction
- Vague abstractions standing in for a concrete referent. "handle the data", "do
  the processing", "manage the state" name nothing. Say what the code does to
  what. This often points at a rename or extraction. Use `/stratify` for those

# What to keep

- Domain terms that began as metaphors but are now the field's precise
  vocabulary: "socket", "stream", "thread", "port", "tree", "branch",
  "deadlock", "handshake", "garbage collection". These are concrete to anyone in
  the domain
- A metaphor that makes a distinction no plain term captures. If replacing it
  would lose real meaning, keep it. Note why in your report
- Terms of art the project already uses consistently, even if you'd pick
  different words. Concretizing should not fork the project's vocabulary. If a
  whole vocabulary needs aligning, use `/ubiquitize-language`
- Anything you don't fully understand. Investigate or leave it. Don't guess a
  word away and lose its meaning

# Fixing mistakes

- A test or typecheck breaks after a rename: a reference was missed or the name
  is used outside the target. Find the other references or restore the original
  name
- A replacement reads less clearly than the metaphor: the metaphor said
  something the plain word doesn't. Put it back and note it as a deliberate keep
