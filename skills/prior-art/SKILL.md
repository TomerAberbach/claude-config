---
name: prior-art
description: |
  Check a design decision against how comparable real tools solved it, citing a
  verifiable source for every claim.
argument-hint:
  '<the decision or artifact to check, e.g. "config precedence order">'
allowed-tools:
  - WebFetch
  - Bash(man *)
---

Check the design decision in the target against how comparable real tools
already solved it, and report what the prior art does, where it disagrees, and
which convention the target should follow. Every claim cites a source.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Check the decision or artifact named in the arguments if given. Otherwise check
the changes in the current commit shown above. If there are no arguments and the
commit has no changes, ask the user what decision to check and stop.

# Principles

- Only real, named, checkable tools count. A tool qualifies when you can point
  at its repository, docs, or source. Never invent an authority: no "the
  convention is", no unnamed "most CLIs", no imagined expert, standard, style
  guide, or survey. An uncited generalization is a fabrication even when it
  turns out to be true
- Read the artifact, not your memory of it. Fetch the README, the man page, the
  `--help` output, the schema, the source. Recall is for finding candidates, but
  the source determines what they do
- Three comparables is the minimum. Fewer, and you're reporting one tool's taste
  as a convention. If you can't find three, say so and describe what you found
  instead
- Disagreement is the finding. Where the comparables split, name the split and
  what each side optimizes for. A false consensus is worse than none
- Comparable means same problem, not same domain. A JSON linter and a CSS linter
  share a config-precedence problem; a JSON linter and a JSON parser don't
- Prior art informs, but it doesn't rule. A deliberate divergence with a stated
  reason is a fine outcome. Say when the convention is worth breaking

# Workflow

1. State the decision in one sentence, as a question a tool must answer: "when a
   flag, an env var, and a config file all set the log level, which wins?" If
   the arguments name an artifact rather than a decision, read it and list the
   decisions in it, then pick the ones worth checking
2. Read the target's current answer, from the code, not from its docs. Note
   where in the source it's decided
3. List candidate comparables: tools that face the same question. See "Finding
   comparables". Aim for at least three, spanning more than one ecosystem where
   the question isn't language-specific
4. For each comparable, find its answer in a primary source (see "Sourcing a
   claim"). Record the tool, the answer, and the exact source. Drop any
   candidate whose answer you can't source, and say you dropped it
5. Compare: group the comparables by answer. Note the majority, the splits, and
   any answer nobody chose
6. Rule: does the target match the prevailing answer, sit in a legitimate
   minority, or diverge from all of them? For a divergence, decide whether it's
   deliberate and justified or accidental
7. Report as in "Reporting". Don't change the target unless the arguments or a
   follow-up ask for it

# Finding comparables

- The target's own dependencies and their peers: whatever the manifest already
  pulls in solved nearby problems
- The dominant tool in the space, plus one deliberate reaction to it. The
  reaction usually documents why it diverged, naming the trade-off
- A tool from another ecosystem facing the same question, when the question
  isn't language-specific. Config precedence, exit codes, glob syntax, and flag
  naming all cross language lines
- Awesome-lists, the ecosystem's registry (npm, crates.io, PyPI), and
  "alternatives to X" pages, to enumerate rather than to conclude
- The specification, if one exists: POSIX, XDG, SemVer, Conventional Commits. A
  spec is prior art of a different weight. Say when tools ignore it

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Sourcing a claim

Rank sources by how directly they answer:

1. The tool's source code, for behavior. Best for precedence, defaults, and edge
   cases, where docs lag
2. The tool's own docs: README, man page, `--help`, reference site
3. A changelog, issue, RFC, or PR discussion, for the reason behind the choice
   rather than the choice itself
4. A third party writing about the tool, only when nothing above answers, and
   marked as secondary

For each claim record the tool, the URL or file path plus the line, and the
version or commit when the tool's answer has changed across releases. A claim
you can't attach a source to doesn't go in the report; it goes in the "couldn't
verify" list.

If web access fails or returns nothing usable, say so and report the reduced
coverage. Never fill the gap from memory and present it as sourced.

# Reporting

Open with the decision, the target's current answer, and the verdict in one
sentence: matches prevailing practice, legitimate minority, or diverges.

Then a table or list of comparables, one row each: tool, its answer, and the
source link or path. Follow with:

- The consensus, if there is one, and its size out of how many checked
- The splits: each group, who's in it, and what it optimizes for
- The recommendation: keep, change, or diverge deliberately, with the reason. If
  changing, name the concrete edit
- Coverage: how many comparables you checked, which candidates you dropped and
  why, and every claim you couldn't source
