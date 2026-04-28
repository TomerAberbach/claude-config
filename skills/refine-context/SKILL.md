---
name: refine-context
description: Iteratively improve a context document.
argument-hint: '[file path or document to refine]'
---

Iteratively improve the given context document.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Refine the target named in the arguments if given; otherwise the document
changed in the current commit shown above; if there are no arguments and the
commit has no changes, ask the user what to refine and stop.

# Prepare

- Break prose into point form before iterating. One claim per bullet.

# Iterate

- What are the ambiguities?
- What are the internal contradictions?
- Can any parts be fused?
- Are the most important things first?
- Is the communication specific?
- Is the communication concise?
- What would the reader already know?

# Apply

- One question per iteration.
