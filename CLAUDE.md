# Tools

- `jj`, not `git`

# Workflow

- Run individual tests, not the whole test suite

# Prose style

Apply these rules to all prose you write, including documentation, comments,
docstrings, commit messages, and chat responses.

@skills/humanize/RULES.md

# Comment style

- Don't explain what is evident from the code
- Don't reference specific callers or usages of a function, class, or module;
  just describe the behavior
- Don't leave breadcrumbs or tombstones

## JavaScript/TypeScript

### Tools

- `package.json` scripts, not `npx`
- `node`, not `tsx`
- `pnpm`, not `npm`

### Workflow

- Use `node --input-type=module << 'EOF' ... EOF` to test hypotheses about JS/TS
  code. Prefer `Bash` for everything else

### Code style

- ES modules (`import`/`export`), not CommonJS (`require`)
- Arrow functions, not `function`s
