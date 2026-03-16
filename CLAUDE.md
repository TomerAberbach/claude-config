# Tools

- `jj`, not `git`
- `package.json` scripts, not `npx`
- `node`, not `tsx`

# Workflow

- Use `node --input-type=module << 'EOF' ... EOF` to test hypotheses about
  JS/TS code, and ensure you're using the right default or named export if you
  encounter a `SyntaxError`. Prefer `Bash` for everything else.
- Run individual tests, not the whole test suite

# Code style

- Place classes/functions in decreasing order of abstraction (using before used)
- Early `return`/`continue`/`break` to reduce nesting
- ES modules (`import`/`export`), not CommonJS (`require`)
