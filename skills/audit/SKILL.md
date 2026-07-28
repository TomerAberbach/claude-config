---
name: audit
description: |
  Audit something against a standard, check every item in scope, and report the
  findings and the coverage behind them.
argument-hint: '<what to audit, and against what standard>'
---

Audit the given subject against a standard, check every item in scope, and
report the findings. Report, don't fix.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Audit the subject named in the arguments if given. Otherwise audit the changes
in the current commit shown above. If there are no arguments and the commit has
no changes, ask the user what to audit and stop.

# Principles

- An audit is a completeness claim, not a sampling. A review says "here is what
  I noticed"; an audit says "I checked all of these, and here is what failed"
- The standard comes before the findings. Decide what counts as a failure before
  looking, so the findings aren't rationalized after the fact
- Unchecked items are a finding of their own. Disclose every gap in coverage
- A clean audit is a real outcome. Don't manufacture findings to justify the
  effort

# Workflow

1. State the standard: what property must hold for every item in scope? Derive
   it from the arguments, the project's conventions, or the relevant docs and
   spec. If the arguments name a subject but no standard, propose one in a
   sentence and continue with it, saying in the report that you chose it
2. Enumerate the population: list every item in scope by mechanical means (`rg`,
   a file glob, a manifest, a schema), not from memory. Record the count. See
   "Scoping the population"
3. Write the check: the question asked of one item, and the evidence that
   answers it. Run it against one item you expect to pass and one you expect to
   fail, to confirm it tells them apart
4. Apply the check to every enumerated item. Record each as pass, fail, or not
   checked with the reason
5. Verify each failure before reporting it: re-read the item, and prefer running
   something (a test, a command, a query) over reasoning alone. Drop the
   failures that don't hold up
6. If nothing fails, report the scope and the clean result, then stop
7. Report as in "Reporting". Don't fix anything unless the arguments or a
   follow-up ask for it

# Scoping the population

The audit is only as good as the enumeration. Bound it along whichever of these
fit:

- Files or directories matching a pattern
- Every member of a declared set: exports, routes, endpoints, migrations,
  dependencies, config keys, feature flags, permissions, tables
- Every call site of a function or use of a symbol
- Every entry in a log, changelog, or history over a stated time range
- Every requirement in a spec, checklist, or standard, mapped to where it's
  satisfied

When the population is too large to check in full, say so and either narrow the
scope with the user or state the sampling rule and its limits in the report.
Never truncate silently.

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Reporting

Open with the scope: what was audited, against what standard, how many items,
and how many were checked. Then the findings, ordered by severity, each with:

- The item, by path and line or by identifier
- What the standard requires and what the item does instead
- The evidence: the command run, the output, or the lines read
- The fix, concretely

Mark each finding as confirmed or suspected. Close with what was not checked and
why, and with how much you trust the enumeration.
