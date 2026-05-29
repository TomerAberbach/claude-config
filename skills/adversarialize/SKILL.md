---
name: adversarialize
description:
  Perform a task with a worker agent, critique it with an adversary agent, and
  apply the accepted critiques with a reconciler agent.
disable-model-invocation: true
allowed-tools: Agent
---

Perform the given task by spawning a worker agent, then an adversary agent to
critique the worker's output, then a reconciler agent to apply the critiques you
accept. You orchestrate and judge; the agents do the work.

$ARGUMENTS

# Workflow

1. Identify the task:
   - The task in `$ARGUMENTS`
   - Otherwise, the most recent task under discussion in the conversation
   - If neither exists, ask the user for the task and stop
2. Spawn a worker agent with the task verbatim plus any conversation context it
   needs. Instruct it to perform the task and return what it changed and the
   reasoning behind non-obvious decisions
   - If the task is a slash command, instruct the worker to read that skill's
     SKILL.md (under `~/.claude/skills/` or the project's `.claude/skills/`),
     run any `!`-fenced context blocks as commands, and follow the skill with
     the given arguments
3. Spawn an adversary agent with the original task and the worker's report.
   Instruct it to:
   - Inspect the worker's actual output (diff, files, artifacts), not just the
     report
   - Make no changes: read, run read-only checks, and report
   - Try to refute the work: bugs, gaps, unmet requirements, and unjustified
     decisions
   - Return a numbered list of findings, each with location, problem, and
     suggested fix. Return "no findings" if the work holds up
4. Evaluate each finding yourself; don't delegate this step. Accept a finding
   only if:
   - It's correct. Verify uncertain claims by reading the relevant code or
     output
   - Fixing it serves the original task rather than the adversary's taste
5. If no findings are accepted, report the worker's result plus the rejected
   findings with reasons, and stop
6. Spawn a reconciler agent with the worker's report and only the accepted
   findings. Instruct it to apply exactly those fixes and nothing else
7. Report the worker's result, each finding as accepted or rejected with the
   reason, and what the reconciler changed

# Guidelines

- Run the agents sequentially; each stage depends on the previous one
- Don't perform the task, the critique, or the fixes yourself. Read only to
  verify adversary claims in step 4
- Keep the adversary independent: pass it the task and the worker's report, not
  your own opinion of the work
- Findings about the task statement itself (ambiguous or contradictory
  requirements) go to the user, not the reconciler
- If the reconciler reports changes beyond the accepted findings, spawn it again
  to revert the extras before reporting
