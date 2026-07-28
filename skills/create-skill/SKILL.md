---
name: create-skill
description: |
  Create a new Claude Code skill following the conventions of existing skills.
argument-hint: '[what the skill should do]'
---

Create a new Claude Code skill following the conventions of existing skills.

# Existing skills

```!
ls ~/.claude/skills .claude/skills skills 2>/dev/null || true
```

Arguments: $ARGUMENTS

# Workflow

1. Identify what the skill should do:
   - The description in the arguments
   - Otherwise, the skill most recently discussed in the conversation
   - If neither exists, ask the user what the skill should do and stop
2. Decide where the skill lives (ask if unclear from the request):
   - `~/.claude/skills/<name>/SKILL.md` if useful across projects
   - `<repo>/.claude/skills/<name>/SKILL.md` if it encodes project-specific
     procedures, scripts, or conventions
3. Decide the invocation model (see "Frontmatter")
4. Read the one or two existing skills closest in shape to the new one and
   mirror their structure and tone. Mirror the body, not the frontmatter:
   frontmatter follows the rules below, whatever an older skill does
5. Draft the skill (see "Frontmatter" and "Body")
6. Derive `allowed-tools` (see "Permissions")
7. Write the skill file and summarize the choices made (location, invocation
   model, permissions)
8. Polish the draft (see "Polish")

# Frontmatter

Pick exactly one invocation model:

- User-invoked action (e.g. `jj-split`): Description is a one-sentence summary
  of what the skill does, shown to the user in skill lists. Always add an
  `argument-hint` (see "Other fields") and interpolate the arguments in the body
  (see "Body"), since the user invokes it as a slash command and may pass
  arguments
- Auto-loaded guidance (e.g. `authoring-tests`): set `user-invocable: false`
  plus `paths` globs so the skill loads when matching files are touched.
  Description starts with "Use when..."
- Model-invoked task: no flags. The description is the ONLY context Claude has
  when deciding whether to load the skill, so it must state the trigger: "Use
  when asked to..." with concrete phrasings

Other fields:

- `name`: kebab-case, matches the directory name
- `description`: always a `|` block scalar (`description: |`, then the indented
  lines), however short. A plain scalar breaks on a `: ` anywhere inside it,
  since a `: ` parses as a nested mapping and fails to load the frontmatter
- `argument-hint`: required for user-invoked skills. Text shown after the
  command name, describing the expected arguments (e.g.
  `'[file path or text to review]'`). Use `[...]` for optional arguments and
  `<...>` for required ones. Always quote it: an unquoted `[...]` parses as a
  list
- `arguments`: declare named arguments, referenced as `$<name>` in the body. Use
  named arguments ONLY when the skill is always invoked with one specific value
  and has no conversation fallback. No current skill needs them. Otherwise omit
  them and use `$ARGUMENTS` for free-form input that can also fall back to the
  conversation

# Body

- Open with the description restated as an imperative instruction
- Inject dynamic context with `!`-fenced code blocks, which execute at
  invocation time (e.g. `jj show --git` in `jj-split`). Use them for context the
  skill always needs. If the workflow might stop before using the context,
  gather it in a workflow step instead
- A user-invoked skill (`disable-model-invocation: true`) MUST interpolate its
  arguments in the body, either `$ARGUMENTS` for free-form input or the named
  `$<name>` placeholders, so input passed to the slash command isn't dropped.
  Place it after the dynamic context and before the workflow so user input can
  override the defaults. When later prose refers back to the input, label the
  line `Arguments: $ARGUMENTS` and write "the arguments" thereafter, so a long
  input isn't repeated. Otherwise a bare `$ARGUMENTS` is fine
- Structure: optional `# Goals` or `# Principles`, then a numbered `# Workflow`,
  then how-to and guideline sections the workflow references
- Cross-reference related skills instead of duplicating them: "Before starting,
  load `/authoring-tests`". Verify the referenced skill exists
- NEVER instruct using interactive commands (e.g. `jj split -i`, `git add -p`).
  Claude cannot respond to interactive prompts, so use flag-driven alternatives
- In a workflow that mutates state, verify after each step, define when to stop
  early (e.g. "if the commit is already small, tell the user and stop"), and
  include a fixing-mistakes section when missteps are recoverable
- End open-ended lists of techniques with: "These aren't exhaustive. Reason from
  first principles when none fits cleanly."
- Keep SKILL.md to the procedure. Put large reference material, data, and
  scripts in supporting files in the skill directory and link them from the body
  for on-demand reading
- Wrap prose at 80 columns. No em dashes. No terminal period on a list item,
  even a multi-sentence one, whose internal sentences keep theirs

## Target resolution

A skill that transforms code or prose usually works on either an explicit target
or the current commit's changes. Standardize this with a `# Target` section that
interpolates `jj show --git`, then an `Arguments: $ARGUMENTS` line, then the
precedence: operate on the target named in the arguments if given. Otherwise
operate on the changes in the current commit shown above. If there are no
arguments and the commit has no changes, ask the user what to target and stop.
See `../reuse/SKILL.md` and `../stratify/SKILL.md`.

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

# Polish

Run these passes over the skill file, in order, waiting for each to finish
before starting the next:

1. `/refine-context`
2. `/humanize`

Run each pass in its own subagent, and give that subagent nothing but the path
to the skill file and the instruction to run the one skill on it. Withhold the
request that prompted the skill, the reasoning behind the draft, and the
findings of earlier passes: each pass must read the file cold and judge it as a
reader who has never seen it would, so gaps that seem filled by conversation
context surface as gaps. Tell the subagent to be adversarial: assume the draft
is unclear until the text proves otherwise.

Report what each pass changed.
