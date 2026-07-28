---
name: diagnose-ci
description: |
  Diagnose a failing, cancelled, or hanging CI run, explaining why it fails in
  CI when the same command passes locally.
argument-hint: '<run URL, PR number, or what is failing>'
allowed-tools:
  - Bash(gh run *)
  - Bash(gh pr *)
  - Bash(gh workflow *)
  - Bash(gh api *)
  - Bash(gh repo view *)
  - Bash(rg *)
---

Find the cause of a CI failure and name it, with the evidence that proves it.
Explain the divergence before changing anything.

# Recent runs

```!
gh run list --limit 10 2>&1 | head -20
```

Arguments: $ARGUMENTS

Diagnose the run named in the arguments if given. Otherwise diagnose the most
recent failing run above. If there are no arguments and no run has failed, ask
the user which run to diagnose and stop.

# Principles

- The log is the evidence. Read the failing step before forming a theory. Wrong
  diagnoses come from guessing the error out of the workflow file
- "It passes locally" is the finding, not an objection to it. When one command
  passes on one machine and fails on another, their environments differ. Locate
  the difference, don't patch the symptom
- A cancelled run is not a failure. Cancellation comes from a concurrency group,
  a sibling matrix leg, a timeout, or a person. Each has a different fix
- Reproduce before fixing. CI round trips are slow, so a fix you never saw fail
  is an expensive guess
- Loosening the check is not the fix unless you can say what the check was wrong
  to assert. Raising a timeout, retrying a flaky test, pinning to the one node
  version that passes, committing generated output to satisfy a `--check`: each
  hides the cause

# Workflow

1. Resolve the target to a run ID. From a run URL, take the trailing number.
   From a PR number, use `gh pr checks <n>`. From a repo name alone, use
   `gh run list --status failure --limit 5`
2. Get the run's shape with `gh run view <id>`: the conclusion (failure,
   cancelled, timed out), which jobs failed, and whether one matrix leg failed
   or all of them
3. Isolate the failing step with `gh run view <id> --log-failed`. When that is
   empty, as it is for cancellations and timeouts, read the tail of
   `gh run view --job <job-id> --log`. Quote the first real error, not the
   summary line that follows it
4. Read the workflow file that defines the job at the commit the run used, not
   at HEAD: `gh api repos/{owner}/{repo}/contents/<path>?ref=<sha>`. A
   `pull_request` run uses the merge commit, which you have not checked out
5. Ask whether the failure is deterministic. Compare against earlier runs of the
   same workflow (`gh run list --workflow <file>`): does it fail every run, on
   one matrix leg, on this branch alone, or intermittently? Each answer points
   at a different part of the checklist
6. Walk the checklist for the run's conclusion: "Divergence checklist" when a
   step failed, "Cancelled and hanging runs" when none did. Stop at the first
   item that explains the error, and confirm it against the log or the workflow
   file
7. Reproduce locally under CI's conditions: the same node version, install mode,
   command, flags, and a clean tree. See "Reproducing locally"
8. Report as in "Reporting". Fix only if the arguments or a follow-up ask for
   it, and only once the reproduction fails the way CI does

# Divergence checklist

For "passes locally, fails in CI", in the order worth checking:

- Toolchain version. The leg's node, pnpm, or python differs from yours. Compare
  `node --version` against the leg's `matrix.node` and the `engines` field. When
  one leg fails and its siblings pass, assume this until proven otherwise
- Install mode. CI installs from a frozen lockfile (`npm ci`,
  `pnpm install --frozen-lockfile`); you installed mutably. A lockfile stale
  against `package.json` fails only in CI, and so does a dependency you
  installed locally and never committed
- Dirty local tree. Untracked or uncommitted files make the command pass for you
  and fail on a clean checkout. Run `jj st`, and check whether the failing input
  is gitignored or generated
- Generated files checked, not written. Locally `pnpm format` rewrites files and
  exits 0; CI runs `--check` and exits nonzero. Lockfiles, snapshots, generated
  types, and API reports behave the same way. When the format job fails but
  `pnpm format` is a no-op, CI is checking a file your formatter skips, or
  checking it under a different config
- Runner OS. Case-sensitive filesystem, path separators, line endings, missing
  system binaries, a different shell. An import that resolves on macOS and fails
  on `ubuntu-latest` is a filename casing bug
- Cache. A restored `actions/cache` entry holds stale build output or a stale
  dependency tree. Test by re-running with the cache disabled or the key bumped
- Environment and secrets. A secret is empty on a fork's `pull_request`,
  `CI=true` changes tool behavior (watch mode off, colors off, prompts fail), or
  `NODE_ENV` differs
- Resource limits. The runner has less memory and fewer cores. Out-of-memory
  kills show as exit code 137, or as a bare "Process completed with exit code 1"
  after a heap message
- Parallelism and ordering. A different worker count and test order expose
  shared state and races that a serial local run hides
- Clock, timezone, and locale. The runner is UTC with a C locale, so date
  formatting and sort order differ
- Network. A rate limit on an unauthenticated request, a registry outage, or an
  egress restriction
- Permissions. The `GITHUB_TOKEN` lacks a scope the job needs, so the failure
  appears as a 403 rather than a build error

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Cancelled and hanging runs

When no step failed, the cause is in how the run was scheduled or bounded:

- Concurrency cancellation. A `concurrency` group with
  `cancel-in-progress: true` cancels the older run when a new push lands on the
  same ref. The symptom is a cancellation seconds after a push. Check whether a
  newer run of the same workflow exists for that ref
- Matrix fail-fast. `strategy.fail-fast` defaults to true, so one leg's real
  failure cancels its siblings. Diagnose the leg that failed, not the cancelled
  ones
- Timeout. `timeout-minutes` on the job or step, or the 6 hour default. A hang
  comes from a process waiting on stdin, a watch mode that never exits, a server
  started without a background flag, or a test awaiting a resource CI lacks.
  Compare the step's duration against a passing run's
- Runner starvation. The job never started: no runner matched `runs-on`, or the
  queue timed out. `gh run view <id>` shows it queued rather than running
- Manual or API cancellation. Someone stopped it, or a scheduled workflow was
  disabled after 60 days without repository activity

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Reproducing locally

Match CI's conditions one at a time, cheapest first:

1. Run the workflow file's exact command with its flags, not the friendly alias
   you normally use
2. Switch to the failing leg's toolchain version
3. Reinstall from the lockfile in frozen mode
4. Run against a clean checkout of the run's commit in a scratch directory, so
   untracked files cannot affect the result
5. Set `CI=true` and clear the environment variables CI does not set

If it still passes, the cause is in the runner, not the code. Get more evidence
from CI: re-run with debug logging (`gh run rerun <id> --debug`), or add a
temporary step printing the tool versions, the resolved config, and the git
status.

# Reporting

Open with the cause in one sentence, marked confirmed or suspected. Then:

- The failing step, and the first real error line, quoted
- The divergence: what differs between your machine and the runner, with the
  line of log or workflow file that shows it
- Why it passed locally, stated outright
- The fix: the file and the change
- What you could not check, and what a debug run would settle
