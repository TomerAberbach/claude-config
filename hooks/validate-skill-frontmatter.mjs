#!/usr/bin/env node

import { readFileSync } from 'node:fs'
import { basename, dirname } from 'node:path'

const input = JSON.parse(readFileSync(0, 'utf8'))
const path = input.tool_input?.file_path ?? ''
if (!/skills\/[^/]+\/SKILL\.md$/.test(path)) process.exit(0)

let source
try {
  source = readFileSync(path, 'utf8')
} catch {
  process.exit(0)
}

const fail = problems => {
  console.error(
    `${path} frontmatter:\n${problems.map(problem => `- ${problem}`).join('\n')}`,
  )
  process.exit(2)
}

const frontmatter = /^---\n(.*?)\n---(?:\n|$)/s.exec(source)?.[1]
if (frontmatter === undefined) fail(['No `---` delimited frontmatter block.'])

const { parseDocument, Scalar } = await import('yaml')
const document = parseDocument(frontmatter, { prettyErrors: true })
if (document.errors.length) fail(document.errors.map(error => error.message))

const fields = document.toJS() ?? {}
const problems = []

if (!('description' in fields)) {
  problems.push('No `description` field.')
} else if (typeof fields.description !== 'string') {
  // A `: ` inside a plain scalar turns the field into a nested mapping, so it
  // parses without error but yields the wrong type.
  problems.push(
    '`description` is not text. A `: ` inside a plain scalar makes it a mapping; use a `|` block scalar.',
  )
} else if (document.get('description', true)?.type !== Scalar.BLOCK_LITERAL) {
  problems.push(
    'Write `description: |` and put the text on the following indented lines. Every skill uses the block form, whatever its length.',
  )
}

const directory = basename(dirname(path))
if (!('name' in fields)) {
  problems.push('No `name` field.')
} else if (fields.name !== directory) {
  problems.push(
    `\`name: ${fields.name}\` does not match the directory \`${directory}\`.`,
  )
} else if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(fields.name)) {
  problems.push(`\`name: ${fields.name}\` is not kebab-case.`)
}

if (problems.length) fail(problems)
