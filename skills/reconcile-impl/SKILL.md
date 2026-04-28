---
name: reconcile-impl
description:
  Update implementation to satisfy added, updated, or deleted tests in the
  current commit.
argument-hint: '[extra guidance or areas to focus on]'
---

Update the implementation to satisfy added, updated, or deleted tests in the
current `jj` commit.

# Goals

- Remove dead code made obsolete by deleted tests
- Update implementation to match changed test expectations
- Add implementation for newly tested behaviors

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Reconcile against the tests named in the arguments if given; otherwise the tests
changed in the current commit shown above; if there are no arguments and the
commit has no changes, ask the user which tests to reconcile against and stop.

# Workflow

1. Explore each deleted, updated, or added test file, and identify:
   - Deleted tests (behaviors no longer required)
   - Modified tests (changed expectations, new edge cases, updated behavior)
   - New tests (behaviors to implement)
2. Find the implementation files that the changed tests import or reference
3. Run the relevant tests
4. Examine failing tests and update the implementation as necessary:
   1. If a test was deleted, remove dead code paths that are no longer exercised
   2. If a test expectation changed, update the implementation to match
   3. If a test is newly added, implement the required behavior Go back to step
      3 after making updates until all tests pass
