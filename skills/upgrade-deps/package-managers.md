# Package manager operations

`SKILL.md` names each operation. This file gives the command or config for it
per package manager. An operation marked "none" has no equivalent, so skip the
step that uses it for that manager. Commands outside the pnpm set are not in the
skill's `allowed-tools`, so each one prompts for permission.

## Detection

| Files                           | Manager |
| ------------------------------- | ------- |
| `pnpm-lock.yaml`                | pnpm    |
| `package-lock.json`             | npm     |
| `yarn.lock`                     | yarn    |
| `Cargo.toml`                    | cargo   |
| `pyproject.toml` with `uv.lock` | uv      |
| `go.mod`                        | go      |
| `.github/workflows`             | actions |

## pnpm

- Frozen install: `pnpm install --frozen-lockfile`
- List outdated: `pnpm outdated --format json`, add `-r` in a workspace
- Audit: `pnpm audit --json`. `pnpm audit --fix` writes overrides for transitive
  findings
- Update within ranges: `pnpm update`, add `-r` in a workspace, or
  `pnpm update <names>` for a subset
- Set a version: `pnpm add <name>@<version>`, with `-D` for a dev dependency and
  `--filter <package>` in a workspace. Writes a `^` range
- Explain: `pnpm why <name>`
- Repository: `pnpm view <name> repository.url`
- Override: `pnpm.overrides` in `package.json`. A key of `"<name>@<range>"`
  scopes the override to that range
- Dedupe: `pnpm dedupe`

## npm

- Frozen install: `npm ci`
- List outdated: `npm outdated --json`, add `--workspaces` in a workspace
- Audit: `npm audit --json`. `npm audit fix` upgrades within ranges only
- Update within ranges: `npm update`, or `npm update <names>` for a subset
- Set a version: `npm install <name>@<version>`, with `-D` for a dev dependency
  and `--workspace <package>` in a workspace. Writes a `^` range
- Explain: `npm explain <name>`
- Repository: `npm view <name> repository.url`
- Override: `overrides` in `package.json`. Nesting under a parent name scopes
  the override to that parent
- Dedupe: `npm dedupe`

## yarn (berry)

- Frozen install: `yarn install --immutable`
- List outdated: no non-interactive command. Use `npm outdated --json` against
  the same `package.json`
- Audit: `yarn npm audit --json --recursive`
- Update within ranges: `yarn up -R '*'`, or `yarn up -R <names>` for a subset
- Set a version: `yarn add <name>@<version>`, with `-D` for a dev dependency,
  run inside the workspace package's directory. Writes a `^` range
- Explain: `yarn why <name>`
- Repository: `yarn npm info <name> --fields repository`
- Override: `resolutions` in `package.json`. A key of `"<name>@<range>"` scopes
  the override to that range
- Dedupe: `yarn dedupe`

## cargo

- Frozen install: `cargo fetch --locked`
- List outdated: `cargo outdated --format json` (needs `cargo-outdated`)
- Audit: `cargo audit --json` (needs `cargo-audit`)
- Update within ranges: `cargo update`, or `cargo update <names>` for a subset
- Set a version: `cargo add <name>@<version>`, with `--dev` for a dev dependency
  and `-p <package>` in a workspace. Writes a caret range
- Explain: `cargo tree -i <name>`
- Repository: `cargo info <name>`
- Override: `[patch]` section in `Cargo.toml`. Cannot scope to a range
- Dedupe: none. `cargo update` already unifies where ranges allow

## uv

- Frozen install: `uv sync --frozen`
- List outdated: `uv pip list --outdated`
- Audit: `uv run pip-audit --format json` (needs `pip-audit`)
- Update within ranges: `uv lock --upgrade`, or
  `uv lock --upgrade-package <name>` for a subset, then `uv sync`
- Set a version: `uv add '<name>==<version>'`, with `--dev` for a dev dependency
  and `--package <package>` in a workspace. Writes an exact pin when given `==`,
  otherwise `>=`
- Explain: `uv tree --invert --package <name>`
- Repository: `uv pip show <name>`, the Home-page or Project-URL fields
- Override: `override-dependencies` under `[tool.uv]` in `pyproject.toml`.
  Cannot scope to a range
- Dedupe: none. The resolver keeps one version per package

## go

- Frozen install: `go mod download`, then `go mod verify`
- List outdated: `go list -m -u -json all`
- Audit: `govulncheck ./...` (needs `govulncheck`)
- Update within ranges: `go get -u ./...` moves minors and patches. Majors are
  new module paths, so they never move here
- Set a version: `go get <module>@<version>`. A new major changes the import
  path, so the migration includes rewriting imports
- Explain: `go mod why -m <module>`
- Repository: `go list -m -json <module>`, the Origin field, or the module path
  itself
- Override: `replace` directive in `go.mod`. Cannot scope to a range
- Dedupe: `go mod tidy`

## actions

GitHub Actions has no manager or lockfile. Every
`uses: <owner>/<repo>[/<path>]@<ref>` line in `.github/workflows/*.yml` and in
local composite actions (`action.yml`) is a dependency. Skip `uses:` lines that
start with `./` or `docker://`. A pin takes one of three styles, and an upgrade
keeps the style it found:

- Major tag: `@v4`. Floats within the major, so only a new major is an upgrade
- Exact tag: `@v4.2.1`
- Commit SHA: `@<40-char sha> # v4.2.1`. The comment records the tag. Write the
  new tag's commit SHA and update the comment

Operations:

- Frozen install: none
- List outdated: `grep -rhoE 'uses: *[^ #]+' .github` for the pins, then
  `gh api repos/<owner>/<repo>/releases/latest --jq .tag_name` for each latest
  version. A repository without releases has only tags:
  `gh api repos/<owner>/<repo>/tags --paginate --jq '.[].name'`, and take the
  highest semver tag
- Audit:
  `gh api '/advisories?ecosystem=actions&affects=<owner>/<repo>@<version>'`. For
  a SHA pin, use the tag from its comment
- Update within ranges: none. A major tag already tracks its major
- Set a version: rewrite every `uses:` line for that action, in every workflow
  file, to the new ref. For a SHA pin, resolve the tag with
  `gh api repos/<owner>/<repo>/commits/<tag> --jq .sha`
- Explain: `grep -rn '<owner>/<repo>' .github` lists the workflows that use it
- Repository: `github.com/<owner>/<repo>`
- Override: none
- Dedupe: none. Bring every use of one action to the same ref

Verify an upgrade against the new version's `action.yml` (or `action.yaml`),
fetched with
`gh api 'repos/<owner>/<repo>/contents/[<path>/]action.yml?ref=<tag>' --jq .content | base64 -d`.
Check that every `with:` key the workflow passes is still an input, every
required input is passed, and every `steps.<id>.outputs.<name>` the workflow
reads is still an output. A new `runs.using` (such as `node24`) is a runtime
requirement when the workflow runs on self-hosted runners whose version predates
it.
