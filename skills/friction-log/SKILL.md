---
name: friction-log
description: |
  Attempt a task in a clean-room Claude Code session that has none of this
  session's context and none of the project's agent instructions, and report
  the friction log it kept.
argument-hint: '<task for the clean-room run to attempt>'
allowed-tools:
  - Bash(cd *)
  - Bash(claude -p *)
  - Bash(mkdir -p *)
  - Bash(cp -R *)
  - Bash(jj root *)
  - Bash(jj workspace add *)
  - Bash(jj workspace forget *)
  - Bash(git rev-parse *)
  - Bash(git worktree add *)
  - Bash(git worktree remove *)
---

Have a Claude Code session that knows nothing about this project (the runner)
attempt a task, keep a friction log while it works, and report that log. The
result is the log, not the finished task: every place the project cost the
runner a step it should not have needed.

Arguments: $ARGUMENTS

The arguments name the task. If they name none, ask the user what task to
attempt and stop.

# Why a clean room

The `Agent` tool does not give one. A subagent inherits the user's global
`CLAUDE.md`, the project's `CLAUDE.md`, the auto-memory index, and the skill
list. Every one of those exists to prevent the friction this skill measures, so
a subagent's log understates it.

`claude --safe-mode` does give one: it disables every `CLAUDE.md`, skill,
plugin, hook, MCP server, and custom agent, while auth, model selection, tools,
and permissions keep working. The workflow below uses it. Do not substitute the
`Agent` tool for it.

# Workflow

1. Restate the task as a goal plus a definition of done the runner can check
   itself: a command that exits zero, a file that exists, a request that returns
   what it should. Show the restatement to the user and get agreement before
   spending a run
2. Find the repository root and create a throwaway workspace. Never run in the
   user's working tree: the runner works with permission prompts bypassed and
   will edit files. Make a directory under the scratchpad directory (`<scratch>`
   below) and put the workspace at `<scratch>/workspace`. Everything else you
   write goes directly in `<scratch>`, outside the workspace, where the runner
   cannot read it. Use `jj workspace add --name friction <scratch>/workspace` in
   a jj repo, `git worktree add <scratch>/workspace HEAD` in a plain git repo,
   and `cp -R <root>/. <scratch>/workspace` otherwise. For the report, record
   what the workspace lacks compared to the user's working tree: `.env` files,
   installed dependencies, build output. A jj or git workspace has none of the
   ignored files a working tree accumulates, and that is the point. A `cp -R`
   copy includes them, so say so and expect it to hide friction
3. Write the brief to `<scratch>/brief.md`. See "Writing the brief"
4. Tell the user the exact command you are about to run and that the runner
   bypasses permission prompts inside the workspace. Wait for approval
5. Launch it in the background:

   ```
   cd <scratch>/workspace && claude -p --safe-mode \
     --permission-mode bypassPermissions \
     --append-system-prompt-file ~/.claude/skills/friction-log/protocol.md \
     --output-format json "$(cat <scratch>/brief.md)" > <scratch>/result.json
   ```

   Pass `--model` only if the user named one, and `--max-budget-usd` only if
   they set a cap. Do not read the runner's output as it streams. Wait for it

6. Read `<scratch>/workspace/friction-log.md`. The protocol has the runner
   create it even when nothing went wrong, so a missing file means the run died
   before writing one: report the error from `<scratch>/result.json` and stop.
   If the run left the task unfinished, use the partial log and say so
7. Sort every entry into the three categories in "Verifying the log" and drop
   the ones with no evidence
8. Read the `CLAUDE.md` files safe mode hid (the project's and the user's global
   `~/.claude/CLAUDE.md`) and pull every entry they would have answered out of
   the project friction group into its own. An agent that reads them never hits
   those gaps; a human arriving at the project still does
9. Report as in "Reporting"
10. Offer to remove the workspace once the user has the report, not before: the
    diff the runner left is evidence. `jj workspace forget friction`, or
    `git worktree remove <scratch>/workspace`, then delete `<scratch>`

# Writing the brief

The brief is everything the runner will know. Write it as a ticket handed to
someone hired yesterday: the goal in a sentence or two, the definition of done,
and any access it could not discover on its own, such as a URL or a test
account. Forbid anything that reaches outside the workspace: no pushing, no
deploying, no writing to shared services.

Then strip what this session taught you:

- File paths, symbol names, and commands you learned here
- The answer, or its shape ("the handler is already half written")
- Which files it can skip
- Corrections the user made earlier
- Your own conclusions about how the project is laid out

These aren't exhaustive. Reason it out when none fits cleanly.

When the runner cannot find something because the brief withheld it, that is the
finding. Resist helping.

# Verifying the log

Every entry names a command, a file, an error, or a passage the runner read.
Drop the ones that do not. An entry without a trigger is an impression, not a
finding.

Sort the rest:

- **Project friction**: the repository, its docs, its tooling, or its error
  messages caused it. These are the findings
- **Runner friction**: the runner misread something a careful reader would not
  have. Report it separately, with whatever in the project invited the
  misreading
- **Method artifact**: the clean room caused it. Safe mode removed the project's
  `CLAUDE.md`, and the fresh workspace has no `.env`, no installed dependencies,
  no build output. Mark these and keep them out of the ranking

# Reporting

Open with the task, whether the runner finished it, how long it took and what it
cost, the workspace path, and what the fresh workspace lacked.
`<scratch>/result.json` has the duration and the cost.

Then the project friction, worst first, each as: what the runner was doing, what
it expected, what it got, what recovery cost, and the proposed fix, with one
line of evidence.

Then, in order: the entries the hidden `CLAUDE.md` files would have answered,
the runner-caused entries, and the method artifacts, one line each. Close with
the parts of the task the runner never reached, which the run shows nothing
about.

Offer to make the fixes as a follow-up. Make none of them now.
