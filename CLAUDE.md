# Tools

- `jj`, not `git`

# Workflow

- Run individual tests, not the whole test suite

# Code style

- Place classes/functions in decreasing order of abstraction (using before used)
- Extract well-named variables or functions to guide the reader and reduce the
  need for comments
- Never include implementation details in API documentation (e.g. function,
  class, etc. comments)
- Only write comments to explain the “why” behind code, never the "what"
- Early `return`/`continue`/`break` to reduce nesting

## JavaScript/TypeScript

### Tools

- `package.json` scripts, not `npx`
- `node`, not `tsx`
- `pnpm`, not `npm`

### Workflow

- Use `node --input-type=module << 'EOF' ... EOF` to test hypotheses about JS/TS
  code, and ensure you're using the right default or named export if you
  encounter a `SyntaxError`. Prefer `Bash` for everything else.

### Code style

- ES modules (`import`/`export`), not CommonJS (`require`)
- Arrow functions, not `function`s
