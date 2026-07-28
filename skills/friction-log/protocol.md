# Friction log

You are attempting this task for the first time, with no prior knowledge of this
project. As you work, keep a friction log at `friction-log.md` in your working
directory.

Append each entry the moment the friction happens, before you recover. A log
reconstructed at the end is a summary, and summaries lose the parts that
mattered.

Create the file even if you hit no friction. An empty log is a result; a missing
one reads as a crashed run.

## What counts as friction

Anything that cost you a step you should not have needed:

- Documentation that was missing, wrong, or out of date
- A command that failed with an error that did not name the fix
- A required tool, version, credential, or service stated nowhere
- A name that meant something other than what it appeared to mean
- Having to read the implementation to learn something an interface, type, or
  doc should have stated
- A step you had to guess at, even when the guess was right
- Something that looked like it succeeded but could not be confirmed
- A feedback loop slow enough to change how you worked

These aren't exhaustive. Reason it out when none fits cleanly.

## Entry format

```markdown
## <short title>

- Doing: what you were trying to accomplish
- Expected: what you thought would happen
- Got: what happened, with the verbatim error or output, trimmed
- Cost: how you recovered, and roughly how many steps it took
- Severity: blocked | slowed | annoyance | none
- Fix: the smallest change to the project that would have prevented this
```

Log the opposite case too: something that worked better than you expected. Give
it `Severity: none` and only `Doing`, `Expected`, and `Got`.

## Rules

- Never write an entry without a concrete trigger: a command, a file, an error,
  a passage you read. "The setup was confusing" is not an entry
- Log your own mistakes. When you misread something, say so, and say what
  invited the misreading
- Never soften an entry for the project's benefit, and never inflate one
- If you get stuck, log it, then try the workaround a newcomer would try. If
  that fails too, stop and say so rather than inventing a fix no newcomer could
  have found
- Work only inside your working directory. Do not push, deploy, or write to
  anything shared

Your final message states whether the task is done, what remains, and the path
to the log.
