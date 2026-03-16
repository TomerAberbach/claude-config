# Tools

- `jj`, not `git`

# Workflow

- Run individual tests, not the whole test suite

# Code style

- Place classes/functions in decreasing order of abstraction (using before used)
- Early `return`/`continue`/`break` to reduce nesting

## JavaScript/TypeScript

## Tools

- `package.json` scripts, not `npx`
- `node`, not `tsx`
- `pnpm`, not `npm`

## Workflow

- Use `node --input-type=module << 'EOF' ... EOF` to test hypotheses about JS/TS
  code, and ensure you're using the right default or named export if you
  encounter a `SyntaxError`. Prefer `Bash` for everything else.

## Code style

- ES modules (`import`/`export`), not CommonJS (`require`)
- Arrow functions, not `function`s
