---
name: editorialize
description:
  Do an editorial review of a post or article and report findings ordered by
  importance.
argument-hint: '[file path or text to review]'
---

Do an editorial review of the given post or article. Report findings; don't edit
the text.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Review the target named in the arguments if given; otherwise the prose changed
in the current commit shown above; if there are no arguments and the commit has
no changes, ask the user what to review and stop.

# Workflow

1. Read the whole piece once as a reader would, before critiquing
2. Determine the intended audience and the point the piece argues for; the
   passes judge the piece against these
3. Apply the passes in "Passes"
4. If the passes surface nothing significant, tell the user the piece is in good
   shape and stop; don't manufacture findings
5. Report findings in order of importance; a structural problem almost always
   outranks a line-level one. For each: what the problem is, where it occurs,
   why it weakens the piece, and a concrete suggestion
6. Suggest `/strunkify` if the main weakness is loose prose rather than
   substance or structure

# Passes

1. Thesis: can you state the piece's point in one sentence? Does every section
   serve it? Flag sections that don't
2. Audience fit: assumed knowledge, jargon, and depth match the intended reader.
   Flag explanations the audience doesn't need and gaps they do. If the intended
   reader can't be inferred at all, that's the finding
3. Structure: does the order of sections build the argument? Would a reader
   skimming the headings follow the arc?
4. Evidence: are claims supported by examples, data, or reasoning? Flag bare
   assertions a skeptical reader would push back on
5. Counterarguments: are obvious objections acknowledged? Flag the strongest
   unaddressed one
6. Opening: does the first paragraph earn the read, or does it warm up? Flag
   burying the lede
7. Conclusion: does it land the thesis, or trail off into summary and filler?
8. Title: accurate, specific, and matching what the piece delivers; not
   clickbait, not vague
9. Redundancy: points made more than once without adding anything; recommend
   which occurrence to keep
10. Tone: consistent register throughout; flag lurches between formal and
    casual, or confident and hedging

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Guidelines

- Critique the piece the author is writing, not the one you would write
- Be specific: quote or point to the offending passage, never "the middle
  section feels weak"
- Don't flag voice or stylistic choices that are deliberate and consistent
