---
name: create-skill
description:
  Create a new Claude Code skill following the conventions of existing skills.
disable-model-invocation: true
---

Create a new Claude Code skill following the conventions of existing skills.

# Existing skills

```!
ls ~/.claude/skills .claude/skills skills 2>/dev/null || true
```

$ARGUMENTS

# Workflow

1. Decide where the skill lives (ask if unclear from the request):
   - `~/.claude/skills/<name>/SKILL.md` if useful across projects
   - `<repo>/.claude/skills/<name>/SKILL.md` if it encodes project-specific
     procedures, scripts, or conventions
2. Decide the invocation model (see "Frontmatter")
3. Read the one or two existing skills closest in shape to the new one and
   mirror their structure and tone
4. Draft the skill (see "Frontmatter" and "Body")
5. Derive `allowed-tools` (see "Permissions")
6. Write the skill file and summarize the choices made (location, invocation
   model, permissions)
7. Refine the draft by following `../refine-context/SKILL.md` with the new skill
   file as the document
8. Tighten the result by following `../strunkify/SKILL.md` on the skill file

# Frontmatter

Pick exactly one invocation model:

- User-invoked action (e.g. `jj-split`): set `disable-model-invocation: true`.
  Description is a one-sentence summary of what the skill does, shown to the
  user in skill lists
- Auto-loaded guidance (e.g. `authoring-tests`): set `user-invocable: false`
  plus `paths` globs so the skill loads when matching files are touched.
  Description starts with "Use when..."
- Model-invoked task: no flags. The description is the ONLY context Claude has
  when deciding whether to load the skill, so it must state the trigger: "Use
  when asked to..." with concrete phrasings

Other fields:

- `name`: kebab-case, matches the directory name
- `arguments`: declare named arguments, referenced as `$<name>` in the body
  (e.g. `refine-context`'s `document`). Omit and use `$ARGUMENTS` for free-form
  input instead

# Body

- Open with the description restated as an imperative instruction
- Inject dynamic context with `!`-fenced code blocks, which execute at
  invocation time (e.g. `jj show --git` in `jj-split`). Use them for context the
  skill always needs. If the workflow might short-circuit before using the
  context, gather it in a workflow step instead of feeding tokens needlessly
- Place `$ARGUMENTS` after the dynamic context and before the workflow so user
  input can override the defaults
- Structure: optional `# Goals` or `# Principles`, then a numbered `# Workflow`,
  then how-to and guideline sections the workflow references
- Cross-reference related skills instead of duplicating them: "Before starting,
  read: `../authoring-tests/SKILL.md`". Use a relative path within the same
  skills directory and `~/.claude/skills/<name>/SKILL.md` from a project skill
  to a user skill. Verify the referenced skill exists
- NEVER instruct using interactive commands (e.g. `jj split -i`, `git add -p`).
  Claude cannot respond to interactive prompts; use flag-driven alternatives
- Workflows that mutate state should verify after each step, define when to stop
  early (e.g. "if the commit is already small, tell the user and stop"), and
  include a fixing-mistakes section when missteps are recoverable
- End open-ended lists of techniques with: "These aren't exhaustive. Reason from
  first principles when none fits cleanly."
- Keep SKILL.md to the procedure. Put large reference material, data, and
  scripts in supporting files in the skill directory and link them from the body
  for on-demand reading
- Wrap prose at 80 columns. No em dashes

# Permissions

1. List every tool use the body requires: Bash commands (including those in
   `!`-fenced context blocks), `WebFetch` domains, and MCP tools
2. Drop the ones already allowed by `~/.claude/settings.json` (for project
   skills, also check the project's `.claude/settings.json`)
3. Add the rest as `allowed-tools` entries, scoped as narrowly as possible:
   `Bash(jj split *)`, not `Bash(jj *)`
4. If a needed tool matches a settings `deny` rule, flag the conflict to the
   user: deny rules are evaluated before skill `allowed-tools` and block the
   tool even while the skill is active
