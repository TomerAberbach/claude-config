# Tools

- `jj`, not `git`

# Workflow

- Run individual tests, not the whole test suite

# Prose style

Apply these rules to all prose you write, including documentation, comments,
docstrings, commit messages, and chat responses.

@skills/humanize/RULES.md

# Comment style

- NEVER explain what is evident from the code
- NEVER reference specific callers or usages of a function, class, or module;
  just describe the behavior
- NEVER leave breadcrumbs or tombstones

## JavaScript/TypeScript

### Tools

- `package.json` scripts, not `npx`
- `node`, not `tsx`
- `pnpm`, not `npm`

### Workflow

- Use `node --input-type=module << 'EOF' ... EOF` to test hypotheses about JS/TS
  code; on a `SyntaxError`, check you're using the right default or named
  export. Prefer `Bash` for everything else

### Code style

- ES modules (`import`/`export`), not CommonJS (`require`)
- Arrow functions, not `function`s
