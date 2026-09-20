---
name: upgrade-deps
description: |
  Upgrade every dependency as far as possible without breaking the project or
  its downstream consumers, fix reported security vulnerabilities, and report
  each dependency held back from latest and why.
argument-hint: '[dependencies to focus on or extra guidance]'
allowed-tools:
  - Bash(pnpm outdated *)
  - Bash(pnpm audit *)
  - Bash(pnpm update *)
  - Bash(pnpm add *)
  - Bash(pnpm remove *)
  - Bash(pnpm install *)
  - Bash(pnpm why *)
  - Bash(pnpm view *)
  - Bash(pnpm ls *)
  - Bash(pnpm dedupe *)
---

Upgrade every dependency of this project as far as possible without breaking the
project or its downstream consumers. Fix reported security vulnerabilities,
including ones in transitive dependencies. Report each dependency held back from
its latest version and why.

# Project state

```!
ls package.json pnpm-lock.yaml pnpm-workspace.yaml package-lock.json yarn.lock Cargo.toml pyproject.toml uv.lock go.mod 2>/dev/null | head -20
```

```!
jj st 2>&1 | head -20
```

Arguments: $ARGUMENTS

If the arguments name dependencies, upgrade only those. Otherwise upgrade all of
them. Any other guidance in the arguments overrides the defaults below.

# Operations

The workflow refers to package manager operations by name. The files above
identify the package manager, and `package-managers.md` maps each operation to
that manager's command or config, along with its workspace flags, range syntax,
and override syntax. Read it before step 1.

- Frozen install: install exactly what the lockfile records
- List outdated: each dependency's current, wanted, and latest versions
- Audit: known vulnerabilities in the installed tree
- Update within ranges: move every dependency to the newest version its declared
  range allows
- Set a version: change one dependency's declared version and reinstall
- Explain: the chain of dependencies that pulls in a given package
- Repository: the source repository of a package
- Override: force one version of a transitive dependency
- Dedupe: collapse duplicate copies the lockfile no longer needs

# Workflow

1. Establish the baseline. If the working copy has changes, tell the user and
   stop, so the upgrade gets its own commit. Run a frozen install, then the
   project's checks (typecheck, lint, tests, and build, from its manifest
   scripts or CI config). Record which already fail and leave them failing
2. Gather the upgrade list with list outdated and the vulnerability list with
   audit. If both are empty, tell the user everything is current and stop
3. Update within ranges, in one batch. Verify (see "Verifying"). If the batch
   fails, bisect it: revert the manifest and lockfile with `jj restore` and
   reinstall, then update half of the names at a time until you find the
   dependency that breaks a check. Hold that one back and continue with the rest
4. Upgrade each dependency still outdated after step 3, one at a time, or one
   group at a time when dependencies must move together (a framework and its
   plugins, a test runner and its coverage provider, a linter and its configs).
   For each:
   1. Check "Reasons to hold back". Record and skip a dependency that hits one
      without attempting the upgrade
   2. Read the release notes or migration guide for every major between the
      current and latest version. Repository gives the source repository, and
      its releases or CHANGELOG page lists the breaking changes
   3. Set the version to latest, keeping the dependency in the same group (dev,
      runtime, or peer) and the same workspace package, then apply the code
      migrations the release notes require. If the manager rewrites the range
      style, restore the project's own style (caret, tilde, or exact)
   4. Verify. If verification fails and the fix is unclear after one attempt,
      set the version back to the previous one and undo the code migration by
      editing, because `jj restore <file>` would also discard migrations from
      earlier upgrades in the same file. Record the failing check and the
      version reached
   5. Retry with the highest major below the one that failed. Repeat until a
      major passes or none remains above the current one
5. Fix vulnerabilities. Re-run audit and apply to each finding the first rule in
   "Security fixes" that fits. Then test each override that predates this run:
   delete it, reinstall, re-run audit, and put it back only if its finding
   returns
6. Dedupe, then run every check one final time
7. Report as in "Reporting"

# Verifying

After every upgrade step, run the project's checks in the order that fails
fastest: typecheck, lint, tests, build. Run the whole test suite, because a
dependency change can break any test. A check that failed in the baseline still
counts as passing. Any other failure means the step broke something.

For a type failure, read the dependency's release notes for a renamed or removed
export before editing the project's code. For a test failure, decide whether the
dependency changed behavior the test relied on or the test asserted an
implementation detail, then change the project's code in the first case and the
test in the second. Don't loosen or pin the dependency's range as a fix. If you
find no fix, hold the dependency back as in step 4.4.

# Reasons to hold back

Record the reason with the dependency:

- Runtime requirement. The new version requires a language, runtime, or compiler
  version above what the project's declared minimum or CI matrix supports.
  Raising the minimum is the user's decision, so hold back unless the arguments
  allow it. For a published package, list it under "Requires a major release" in
  the report
- Public type leak. The package is published and the dependency's types appear
  in its exported signatures, or the dependency is a peer dependency that
  consumers install themselves. A major bump is then a breaking change for every
  consumer. Hold back, and list it under "Requires a major release" in the
  report
- Peer conflict. Another dependency's compatible range excludes the new version.
  Hold back, record which dependency, and retry after that dependency's own turn
  in step 4
- Module format. The new version ships only a module format the project or its
  consumers cannot load
- Deprecated or renamed. The latest version is deprecated, or the dependency has
  moved to a new package name. Record the replacement instead of upgrading, and
  switch to it only if the arguments ask for that
- Migration failed. Verification failed after the migration and the fix was
  unclear after one attempt. Record the check that failed and the version
  reached
- Pinned on purpose. A comment, an override, or a commit message explains why
  the dependency is pinned. Keep the pin and quote the reason

Other reasons exist. Record one in the same form: what blocks the upgrade and
what would unblock it.

# Security fixes

For each audit finding, apply the first rule that fits:

1. The vulnerable package is a direct dependency: upgrade it as in step 4. If a
   reason to hold back blocks the fixed version, record the finding under
   "Vulnerabilities" with that reason so the user can decide
2. The vulnerable package is transitive and the direct dependency that pulls it
   in has a newer version without it: explain shows that direct dependency.
   Upgrade it as in step 4
3. The vulnerable package is transitive and no direct dependency upgrade removes
   it: add an override that pins the fixed version, scoped to the vulnerable
   range where the manager supports scoping, so unrelated copies stay untouched.
   Verify, because an override changes the version a direct dependency runs
   with. If verification fails, remove the override, reinstall, and record the
   finding as unfixable with the failure
4. No fixed version exists: record the finding as unfixable, with the chain from
   explain

# Reporting

Give the user:

- Upgraded to latest: a count, and the list only if the arguments ask for it
- Held back: a table with the dependency, the version it started at, the version
  it reached, the latest version, and the reason from "Reasons to hold back"
- Requires a major release: the held-back dependencies whose only obstacle is a
  breaking change for consumers, so the user can batch them into one release
- Vulnerabilities: each finding with what fixed it (upgrade or override), and
  each unfixable one with its chain and the failure or hold-back reason
- Code changes: each migration applied, in one line, so the reviewer knows why a
  source file changed in a dependency commit
