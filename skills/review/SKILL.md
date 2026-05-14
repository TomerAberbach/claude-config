---
name: review
description:
  Review added, updated, and deleted code for accuracy, performance, security,
  and maintainability.
disable-model-invocation: true
---

Review added, updated, and deleted code for accuracy, performance, security, and
maintainability.

# Recently changed files

```!
jj show --git
```

$ARGUMENTS

# Workflow

1. For each changed code path:
   1. Find all usage sites across the codebase
   2. Read each usage to determine the concrete types and values passed
   3. Trace each distinct input through the changed code and note:
      - Which branches it exercises
      - Whether any new error path is reachable
      - Whether the return value or side effects changed for that input
      - Validate uncertain hypotheses by running the code for that input
   4. Once an issue is found, skip remaining usage sites for this code path and
      move onto the next
2. Flag all issues found during tracing, following the guidelines below

# Guidelines

## Issue flagging

Only flag an issue when it meets all requirements:

1. Meaningfully impacts accuracy, performance, security, or maintainability
2. Introduced by the code changes
3. There's no plausible reason the author would have written it this way
4. Fixing it does not demand more rigor than the rest of the codebase

If there are no issues, don't flag any.

## Comments

When flagging an issue, provide a comment that meets all requirements:

1. Corresponds to a single distinct issue
2. Clear about why the issue is valid
3. Body is one paragraph. No line breaks except before/after code
4. No code chunks longer than 3 lines. Wrap in inline code or a code block
5. Communicates the scenarios, environments, or inputs that are necessary for
   the issue to arise
6. Tone should be matter-of-fact: avoid flattery, accusatory language, and
   filler phrases
7. Includes a file path and line range when applicable; choose the shortest
   subrange that pinpoints the problem

At the beginning of the comment, tag the issue with a priority level:

- [P0] Critical. Only for issues that affect all inputs with no assumptions
- [P1] Urgent. Affects a meaningful subset of inputs or a common code path
- [P2] Normal. Affects uncommon inputs or edge cases
- [P3] Low. Nice to have

## Evaluating correctness

At the end of your findings, output an "overall correctness" verdict of whether
or not the patch should be considered "correct":

1. Correct implies the code changes are free of bugs
2. Ignore non-blocking issues such as style, formatting, typos, documentation,
   and other nits
3. Do not explain why the code changes are correct. Only explain why code
   changes are incorrect

## Example formatting

> # Issues
>
> [P0–P3] Title: Summary line
>
> Paragraph.
>
> [P0–P3] Title: Summary line
>
> Paragraph.
>
> # Overall correctness
>
> Verdict (NEVER explain if the code changes are correct).
