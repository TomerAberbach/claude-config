---
name: humanize
description: |
  Revise prose for clarity and humanity.
argument-hint: '[file path or text to tighten]'
---

Make the given prose clear and human.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Revise the target named in the arguments if given. Otherwise revise the prose
changed in the current commit shown above. If there are no arguments and the
commit has no changes, ask the user what to revise and stop.

# Workflow

1. Read the target's prose
2. Apply the rules in `RULES.md` to the prose
3. For a file, edit it in place. Otherwise, output the revised prose
4. If you made changes, go back to step 1
5. Report:
   - The number of times step 2 changed the prose
   - Each passage a rule flagged that you kept anyway, and why
   - Each tic you cut that no rule covers
