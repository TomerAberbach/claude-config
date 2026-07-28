---
name: reconcile-impl
description: |
  Update implementation to satisfy added, updated, or deleted tests in the
  current commit.
argument-hint: '[extra guidance or areas to focus on]'
---

Update the implementation to satisfy added, updated, or deleted tests in the
current `jj` commit.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Reconcile against the tests named in the arguments if given. Otherwise reconcile
against the tests changed in the current commit shown above. If there are no
arguments and the commit has no changes, ask the user which tests to reconcile
against and stop.

# Goals

- Implement newly tested behaviors
- Update the implementation to match changed test expectations
- Remove the code that deleted tests left dead

# Workflow

1. Read each added, updated, or deleted test file, and identify:
   - Added tests (behaviors to implement)
   - Updated tests (changed expectations and new edge cases)
   - Deleted tests (behaviors no longer required)
2. Find the implementation files that the changed tests import or reference
3. Run the relevant tests
4. Examine the failing tests and update the implementation:
   - If a test was added, implement the behavior it requires
   - If a test was updated, update the implementation to match
   - If a test was deleted, remove the code paths no test exercises
5. Go back to step 3 after each update, until every relevant test passes
