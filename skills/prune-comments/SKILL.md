---
name: prune-comments
description: |
  Remove unnecessary comments from code: tombstones, redundant restatements,
  and comments a well-named variable or function would replace.
argument-hint: '[file, module, or function to prune]'
---

Remove unnecessary comments from the target code: comments about the code's past
or future, comments that restate what the code plainly does, and comments a
well-named variable or function would replace. Cut whole comments or the dead
clauses inside one. Leave the comments that earn their place, and say so when
none can go.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Prune the target named in the arguments if given; otherwise the code changed in
the current commit shown above; if there are no arguments and the commit has no
changes, ask the user which code to prune and stop.

# Principles

- A comment must say something the code cannot. Code states what it does;
  comments are for what it can't show: why this way, what would break, where the
  rule comes from. A comment that only restates the code it sits on is noise the
  reader must check against the code anyway.
- The best fix for a redundant comment is often a name, not deletion. When a
  comment exists because a variable, function, or step is poorly named, the
  comment is a patch over the real problem. Renaming or extracting removes the
  need for the comment and improves the code. This is `stratify`'s job; see
  "Replacing a comment with a name".
- Comments don't keep history; version control does. A comment about what the
  code used to be, will become, or changed is a tombstone: it decays the moment
  the surrounding code moves on, and the reader can't trust it. An uncommitted
  change counts too. A comment narrating an edit just made while iterating
  (`// changed to a Map`, `// now handles null`) is a tombstone still: the edit
  that produced the code is invisible and irrelevant to anyone reading the
  result.
- Cut the clause, not always the comment. A comment can be half signal, half
  noise: a real warning followed by a restatement of the next line. Trim the
  dead clause and keep the live one.
- When in doubt, keep it. Deleting a comment that carried real intent loses
  knowledge that may be expensive to recover. A comment you don't understand may
  carry meaning the code doesn't show; investigate or leave it, don't guess it
  away.
- Touch comments, not behavior. This skill edits comments and, where it replaces
  one with a name, performs that single rename or extraction. It does not
  rewrite logic. If a comment reveals a bug, report it; don't silently fix it.

These principles double as the test for a cut: remove a comment only when the
code still tells the reader everything the comment did. They aren't exhaustive;
reason from first principles when none fits cleanly.

# Workflow

1. Read the whole target once so you understand what the code does before
   judging any comment against it. Note how to run its tests or typecheck.
2. For each comment, classify it against "What to cut" and "What to keep". Most
   comments are keeps; that's expected.
3. If no comment can be cut or trimmed, tell the user and stop. Don't
   manufacture cuts to look productive.
4. Apply the cuts:
   - For a removal or a partial trim, edit the comment directly.
   - For a comment a name would replace, follow "Replacing a comment with a
     name".
5. If you renamed or extracted anything, run the covering tests or a typecheck
   to confirm behavior is unchanged. Pure comment deletions can't change
   behavior and need no test run.
6. Report what changed: each comment cut and why (tombstone, redundant, replaced
   by a name), each clause trimmed, and the comments you deliberately kept that
   the user might expect you to have cut, with the reason.

# What to cut

- Tombstones: comments about the past, the future, or the change in progress.
  `// used to use a Map here`, `// TODO: rename once #1234 lands` that has
  landed, `// changed to handle the null case`, `// new implementation`,
  `// legacy`. Commented-out code is a tombstone too; delete it.
- Redundant restatements: comments that say what the next line evidently does.
  `// increment the counter` above `count++`, `// loop over the users` above the
  loop, `// return the result` above the return, a docstring that only repeats
  the function's name back in spaced-out words.
- Section labels that name a step the code should name itself:
  `// validate input`, `// now build the request`. These are usually a sign to
  extract a named function (see below), not just to delete the label.
- Caller references in API documentation: a doc comment describes the API itself
  (its contract, parameters, return value, invariants) for every reader, present
  and future. A clause naming who calls it or how a specific caller uses it
  (`// called by the checkout flow to total the cart`,
  `// the dashboard relies on this being sorted`) is stale-prone and overly
  prescriptive: callers come and go, the code records who calls what, and the
  doc shouldn't presume one caller's use is the API's purpose. Trim the caller
  clause; keep whatever describes the API. If the caller's usage reveals a real
  contract (the result must be sorted, say), restate it as an API invariant, not
  a fact about that caller.
- Dead clauses inside a live comment: trim the half that restates the code and
  keep the half that explains it.

# What to keep

- Why, not what: rationale, trade-offs, the reason for a non-obvious choice.
- Warnings and invariants: "must stay in sync with X", "callers hold the lock",
  "order matters here", off-by-one rationale.
- Pointers to outside context: links to issues, specs, RFCs, papers, or the
  source of a magic constant.
- Live TODOs and FIXMEs that still describe real, pending work.
- Legal and license headers.
- API documentation comments that feed docs or IDE hovers, even when redundant
  with the signature; they serve readers who never see the source. Trim a dead
  clause within one, but don't delete the doc comment. Trim a clause that
  describes specific callers rather than the API (see "Caller references in API
  documentation" above).
- Anything you don't fully understand. Investigate or leave it.

# Replacing a comment with a name

When a comment exists only because something is poorly named or because a block
of code needs a label, the fix is to name the thing, not to delete the comment
and lose the intent.

- A comment explaining a cryptic expression often means a well-named
  intermediate variable should hold it: `// minutes until the token expires`
  becomes a `minutesUntilExpiry` variable, and the comment goes.
- A section-label comment marking a phase of a long function often means that
  phase should be an extracted, named function.

These are `stratify`'s extractions. Run `/stratify` to perform the rename or
extraction so it stays a pure, behavior-preserving move, then delete the
now-redundant comment. Keep these changes small and local; if the cleanup grows
into a real refactor, hand it to `stratify` as its own task rather than doing it
here.

# Fixing mistakes

- A test or typecheck breaks after a rename or extraction: the move wasn't pure.
  Revert that one change and redo it, or leave the comment in place if you can't
  make the move cleanly.
- You cut a comment and then realize it carried intent the code doesn't show:
  restore it. Losing rationale is worse than keeping a slightly verbose comment.
