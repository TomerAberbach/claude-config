---
name: issue
description: |
  Write, fill in, or update a GitHub issue, including an upstream bug report
  with a minimal reproduction, and judge replies to it.
argument-hint: '[issue number, URL, draft file, or what to report]'
allowed-tools:
  - Bash(gh issue *)
  - Bash(gh repo view *)
  - Bash(gh search *)
  - Bash(gh api *)
  - Bash(npm view *)
  - Bash(pnpm view *)
  - Bash(node --input-type=module *)
---

Write an issue a maintainer can act on without asking a follow-up question.
Evidence first, then the ask.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Work on the issue, draft, or reply named in the arguments if given. Otherwise
work on the problem visible in the current commit shown above. If there are no
arguments and the commit has no changes, ask the user what to file and stop.

# Modes

Pick one from the arguments:

- Draft: no issue exists yet. Produce a title and a body
- Fill in: a partial draft or a template with blanks exists. Complete it in
  place and leave the author's wording alone where it already says what it means
- Update: an issue exists and the work changed what it should say. Edit it with
  `gh issue edit`
- Judge a reply: a maintainer or another user responded. Assess the response and
  draft an answer. Don't post it

# Workflow

1. Identify the repo and the mode. For an issue number or URL, read it first:
   `gh issue view <n> --comments`
2. Read the repo's contributing rules and issue templates before writing:
   `gh api repos/{owner}/{repo}/contents/.github/ISSUE_TEMPLATE`. A template's
   sections state what the maintainer needs, so follow it
3. Search for duplicates:
   `gh search issues --repo <repo> <keywords> --state all`. Link the closest
   match. If it is the same bug, say so and stop
4. Establish the facts in "What a report must contain". Mark as unverified
   anything you could not check. Never guess
5. For a bug, reduce to a minimal reproduction per "Minimal reproduction". Run
   it. A repro you have not executed does not go in the issue
6. Write the body per "Body shape", and propose a title per "Title". For a
   reply, follow "Judging a reply" instead
7. Show the user what you wrote and stop, unless the arguments ask you to post
   or edit. Never post a comment, close, label, or assign unless asked
8. When asked to update an issue, use `gh issue edit <n> --body-file <path>`,
   and `gh issue edit <n> --title <title>` to retitle. Verify with
   `gh issue view <n>`

# What a report must contain

- What you did, precisely enough to redo: the command, the input, the code
- What happened: the actual output, error, or stack trace, quoted verbatim
- What you expected instead, and why. The "why" is what the maintainer agrees or
  disagrees with, so state it: the docs say X, the type says Y, the previous
  version did Z
- Versions: the package version, the runtime version, the OS. Read them, don't
  recall them: `node_modules/<pkg>/package.json` for what you ran,
  `npm view <pkg> version` for whether a newer release already fixed it
- Whether it regressed, and from which version. A bisect between two published
  versions is worth more than the rest of the report combined
- Scope: does it reproduce on a clean install, in another runtime, with the
  minimal config?

# Minimal reproduction

Cut until removing anything more makes the bug disappear:

1. Strip your application. Nothing from your codebase should remain except the
   call that fails
2. Remove every dependency but the one you are reporting against. A bug that
   needs a second package is a finding, and it belongs in the issue
3. Reduce the input to the smallest value that still fails, and note the nearest
   value that passes. The boundary is the diagnosis
4. Make it runnable as one paste: a single file, exact commands, no scaffolding
   the reader has to invent
5. Run it from a scratch directory on a clean install, so nothing in your local
   environment affects it

If it will not reduce further, say what you tried and where it stopped
shrinking. A half-reduced repro with that note beats a link to a private repo.

# Body shape

Lead with one sentence naming the defect. Then, in this order: reproduction,
actual, expected, environment, and only then any theory about the cause. A
maintainer reading the first three lines should know whether it is their bug.

- Separate what you observed from what you infer. Label the theory as a theory
- Offer to send a patch if you have one, and link the line you would change
- Cut the story of how you found it
- Split unrelated problems into separate issues
- Match the project's tone. Leave headings and emoji out of an issue on a terse
  repo

# Title

A title is a claim, not a topic: name the symptom and the condition that
triggers it, in the project's own vocabulary. `formatDuration` rounds `999.5ms`
up to `1s`, not "rounding bug". Skip "bug:" and "issue:" prefixes unless the
repo's issues use them. Offer one title, plus an alternative when the framing is
arguable.

# Judging a reply

Answer these questions before drafting a response:

- Did they understand the report? If not, the fix is a clearer repro, not a
  rebuttal
- Is their objection right? Check it against the code and the docs instead of
  defending the filing. Say plainly when they are correct
- What do they want next? A version bump, a smaller repro, a PR, a decision from
  you. Do that thing

Then draft a reply that contains new information: a result, a narrowing, a repro
they can run. A reply that only restates the issue costs the maintainer a read
and returns nothing. If it is a "won't fix" you accept, say so and let the
thread close.

# Guidelines

- Assume the maintainer is busy and unpaid. Length is a cost you impose
- Never invent a version, an error message, or an output you did not see
- Don't editorialize about severity. Show the impact and let them rank it
