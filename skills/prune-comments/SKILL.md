---
name: prune-comments
description: |
  Remove unnecessary comments from code: tombstones, redundant restatements,
  and comments a well-named variable or function would replace.
argument-hint: '[file, module, or function to prune]'
---

Remove unnecessary comments from the target code. Cut whole comments or the
unnecessary clauses inside one. Leave the comments worth keeping, and say so
when none can go.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Prune the target named in the arguments if given. Otherwise prune the code
changed in the current commit shown above. If there are no arguments and the
commit has no changes, ask the user which code to prune and stop.

# Workflow

1. Read the whole target's code and comments, so you understand what the code
   does before judging any comment against it. Note how to run its tests or
   typecheck
2. Apply the rules in `RULES.md` to each comment. Most comments are keeps
   - Edit a removal, a partial trim, or a rewording directly, keeping every fact
     the comment stated
   - Where a rule replaces a comment with a name, run `/stratify` to perform the
     rename or extraction, then delete the comment. Keep the move small and
     local, and hand it to `stratify` as its own task if it grows beyond a
     single rename or extraction
   - Read the body before resolving a doc comment narrower than the name above
     it. A body that treats every input alike is general, so state the general
     rule in the doc and drop the specific case. A body that handles one case is
     specific. Rename it after that case
3. If you made changes, go back to step 1. A rename or an extraction moves code
   the earlier pass judged comments against. A rewording can leave a comment
   another rule then cuts
4. If the first pass changed nothing, tell the user and stop. Don't manufacture
   cuts to look productive
5. Where a rule cut a comment that appears verbatim outside the target, list
   those sites once and ask whether to prune them too. Prune them if the user
   agrees. Otherwise cut it in the target alone and report the copies you left
6. If you renamed or extracted anything, run the covering tests or a typecheck
   to confirm behavior is unchanged. Comment-only edits need no test run
7. Report:
   - The number of times step 2 changed the code
   - Each comment cut, trimmed, or reworded, as its location and the rule that
     changed it. The diff shows the text
   - Each comment a rule flagged that you kept anyway, quoted in full, marking
     the clause that states what the code doesn't. Where you can't mark one, the
     comment doesn't state it. Matching another file is not a reason
   - Each comment you cut that no rule covers

# Fixing mistakes

- A test or typecheck breaks after a rename or extraction: the move changed
  behavior. Revert that one change and redo it, or leave the comment in place if
  no version of the move preserves behavior
- You cut a comment and then realize it stated intent the code doesn't show:
  restore it and accept the verbosity
