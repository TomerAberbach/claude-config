# Comment rules

Each rule's Bad and Good differ in one respect: the rule's own. The cutting
rules aren't exhaustive. Cut a comment they don't cover when one of them would
cut it for the same reason. The keeping rules are exhaustive in the other
direction: a comment one of them protects stays, whatever else it looks like.

A rule about a function's name, body, or callers applies to anything a comment
documents: a file, a module, a class, a constant. A file's name is its path, its
body is its contents, and its callers are its importers.

## Restatement

- Replace a comment restating the code with the reason for it, where you know
  the reason. Delete it where you don't
  - Bad: `// Sort by name` above `users.sort(byName)`
  - Good: `// The API returns users in insertion order` above
    `users.sort(byName)`
  - Bad: `# Retry three times` above the retry loop
  - Good: `# A fourth attempt would exceed the request deadline` above the retry
    loop
  - Good, where the reason isn't recoverable: (nothing)

- Cut a comment that restates the line below it
  - Bad: `// increment the counter` above `count++`
  - Good: `count++`
  - Bad: `# open the config file` above `f = open(path)`
  - Good: `f = open(path)`
  - Good, where the comment states what the line can't:
    `// The API returns users in insertion order` above `users.sort(byName)`

- Delete a doc comment whose only content spaces the name into words. Where the
  other rules leave more, keep the summary as its first line
  - Bad: `/** Parses the config file. */` above `parseConfigFile`
  - Good: (nothing)
  - Bad:
    `/** Returns null when the file is empty, and raises when it is unreadable. */`
  - Good: `Parses the config file.`, a blank line, then those two cases

- Open a doc comment with what the thing is, then a blank line, then its
  particulars
  - Bad:
    `/** new URL escapes every character outside a path's allowed set. Decodes the percent-escapes in a pathname. */`
  - Good: `Decodes the percent-escapes in a pathname.`, a blank line, then the
    sentence on `new URL`

- Delete a doc comment that adds nothing to the signature, including one on a
  public API, because a hover shows the signature
  - Bad: `""":returns: the parsed config"""`
  - Good: (nothing)
  - Good, where the doc states what the types can't:
    `""":returns: None when the file is empty"""`
  - Good, where the language has no signature for a hover to show:
    `# $1=role $2=name` above a shell function

- State what the code guarantees, not the steps it takes
  - Bad: `# Builds a dict of ids, walks the rows twice, then merges the buckets`
    above `def customer_totals(orders)`
  - Good: `# Returns cents, and counts a refunded order as zero`
  - Bad: `/// Loops over the error's sources, keeping the last` above
    `fn root_cause`
  - Good: `/// Returns the error itself when it has no source`
  - Good, where the mechanism is observable to the caller:
    `/// Sorts in place, so existing borrows of the slice become invalid`

- Move a doc comment's implementation detail to the code it explains. Delete it
  where no code needs it
  - Bad: three paragraphs on which prefixes `GENERATED_NAME` matches and misses,
    above `isGenerated`
  - Good: those paragraphs on `GENERATED_NAME`, and no doc on `isGenerated`

- State in a doc what a caller can observe. Cut what the body consults to
  produce it. A name that omits a behavior is no evidence that the behavior is
  contract. The test: a caller can act on a null return, a unit, an ordering, a
  thrown error, or a mutation, and not on the evidence the body matched
  - Bad: above `roleOf`, `Returns the user's role.`, a blank line, then
    `Returns admin for a user whose id appears in the seed table.`
  - Good: the same summary, a blank line, then
    `Returns viewer for an unknown user.`
  - Good, where the mechanism is observable to the caller:
    `/** Compares by identity, so two equal values are distinct keys. */`

- Delete a doc comment on unexported code when the contract you would write is
  the body restated
  - Bad: `/** Returns a file: URL's path, and any other URL's href. */` above an
    unexported `formatURL`
  - Good: (nothing)
  - Good, where the code is exported: keeping the doc, and renaming when a
    better name makes it unnecessary

- Answer a question once per doc comment. Where two paragraphs answer the same
  question, merge them
  - Bad: a doc whose first paragraph states what a pattern matches, whose fourth
    adds another match, and whose fifth states the misses
  - Good: one paragraph for what the pattern matches, and one for what it misses

- Trim a comment's restating clause and keep its explaining clause
  - Bad:
    `// Sorts by size. Ties break on name, so the table is stable across runs`
  - Good: `// Ties break on name, so the table is stable across runs`

## Time

- Cut a comment about what the code used to be, will become, or changed
  - Bad: `// used to be a plain object, now a Map`
  - Good: (nothing)
  - Bad: `// new implementation`
  - Good: (nothing)
  - Good, where the past constrains the present:
    `// A key such as toString resolves to Object.prototype on a plain object`

- Delete commented-out code
  - Bad: `# totals = compute_totals(orders)`
  - Good: (nothing)

- Cut a TODO, FIXME, or XXX whose work is done. Keep one whose work is pending
  - Bad: `// TODO: drop the fallback once #1234 lands`, where #1234 has landed
  - Good: `// TODO: drop the fallback once #1234 lands`, where #1234 is open
  - Bad: `// FIXME: an early return leaks the reader`, where the early return
    now closes it
  - Good: `// FIXME: an early return leaks the reader`

- Cut a comment describing an edit rather than the code
  - Bad: `// now handles null`
  - Good: `// A missing rating is null, so the average excludes the row`

## Scope

- State the rule the code follows, not the input that prompted it
  - Bad: `// Splits a Postgres duration like "1.234 ms" into its value and unit`
  - Good: `// Splits a duration into its value and unit, e.g. "1.234 ms"`
  - Bad: `// Streams the body, for the 4 GB upload that ran out of memory`
  - Good: `// Streams the body, so memory use stays constant at any upload size`

- Cut a clause naming who calls the code, or what the caller uses it for. Where
  the caller's use is a contract, state it as one
  - Bad: `// The dashboard relies on this being sorted by total spend`
  - Good: `// The result is sorted by total spend`
  - Bad: `// Called by the checkout flow to sum the line items`
  - Good: `// Sums the line items`
  - Bad:
    `/** Decodes the percent-escapes in a pathname, recovering the path the crawler stored. */`
  - Good: `/** Decodes the percent-escapes in a pathname. */`

- State a placement rule as an instruction. Cut a description of who shares the
  code
  - Bad: `/** Helpers shared by the handlers that talk to the queue. */`
  - Good: `/** Add a helper here when every queue handler needs it. */`
  - Good, where the directory already places it: (nothing)

- Reference other code by name, not by position
  - Bad: `// the visibility check below still shows it`
  - Good: `// {@link isVisible} still shows it`
  - Bad: `# the flush at the end of the loop emits it`
  - Good: `# flush() emits it`
  - Good, where the position is the fact:
    `// Runs before the resolver, which reads the cache this fills`

- Name the subject instead of "we" or "our"
  - Bad: `// Our columns are 1-based, but source map columns are 0-based`
  - Good:
    `// A Position's columns are 1-based, but source map columns are 0-based`
  - Bad: `// The API returns newest-first, but we store oldest-first`
  - Good: `// The API returns newest-first, but the cache stores oldest-first`

- Link a spec instead of teaching it
  - Bad:
    `/** A tag byte is (fieldNumber << 3) | wireType, where wire type 2 is length-delimited and 0 is a varint. */`
  - Good:
    `/** The tag byte's low three bits are the wire type, see https://protobuf.dev/programming-guides/encoding/. */`
  - Good, where no spec documents it: the shape an emitter writes, stated in
    full

- Cut an overview the name and the contents below it already show
  - Bad: `/** Holds the tokenizer, the value reader, and the error type. */` at
    the top of `json/parse.ts`
  - Good: (nothing)
  - Good, where the overview states what neither the code nor its path shows:
    `/** Every export here assumes the caller holds the write lock. */`

- Delete a file or module doc unless it states an invariant every export shares,
  a placement instruction the directory doesn't give, a link to the spec the
  file implements, or a legal notice
  - Bad:
    `/** Queue helpers, shared by the handlers that talk to the queue, because a handler runs on any transport. */`
  - Good: (nothing)
  - Good, where the doc links the spec the file implements:
    `/** Implements the LZ4 frame format, see https://lz4.org/lz4_Frame_format.md. */`

- Match a doc comment's scope to the body's. Where they differ, fix whichever
  misstates the body
  - Bad: `decodePathname`, documented as decoding the `%2F` a proxy writes, over
    a body that decodes any escape
  - Good: `decodePathname`, documented as percent-decoding a pathname
  - Good: `decodeProxyPathname`, documented as decoding the `%2F` a proxy
    writes, over a body that handles that escape alone

## Names

- Replace a comment explaining an expression with a named variable
  - Bad: `// minutes until the token expires` above `(exp - now) / 60_000`
  - Good: `const minutesUntilExpiry = (exp - now) / 60_000`

- Replace a section label with an extracted function
  - Bad: `# validate the input` above the block that validates it
  - Good: `validate_input(raw)`
  - Good, where the phase mutates several locals and can't be extracted:
    `# validate the input`

- Replace a comment repeated at two sites with a shared named function
  - Bad: `// A relative path would resolve against the process's cwd` above two
    near-identical blocks
  - Good: one `resolveAbsolute` that both call
  - Good, where the sites can't share code: both copies

## Keeping

- Keep a comment stating a reason, a warning, or an invariant, even where the
  code below it does what the comment states
  - Bad: cutting `// Callers hold the lock` above `self.entries.remove(&key)`
  - Good: keeping `// Callers hold the lock`

- Keep a reason specific to this code. Cut one that holds for any code of its
  kind. The test: replace the subject with another of its kind, and a generic
  reason stays true
  - Bad: `// A parser needs a tokenizer, like every parser` at the top of a
    module
  - Good: (nothing)
  - Bad: `// A Python module imports like any other module`
  - Good: (nothing)
  - Good, where the reason is specific to this code:
    `// The tokenizer runs twice, because the first pass resolves macros`

- Keep a pointer to outside context: an issue, a spec, a paper, or the source of
  a magic constant
  - Bad: cutting `// PEP 445 requires this to match the allocator's page size`
    above `PAGE_SIZE = 4096`
  - Good: keeping `// PEP 445 requires this to match the allocator's page size`

- Keep a legal or license header
  - Bad: cutting an SPDX header because nothing below it references the license
  - Good: keeping the SPDX header

- Judge a comment on its own. A copy of it in another file is not a reason to
  keep it, or to place it the same way
  - Bad: keeping `# The daemon must be running` above `ensure_daemon` because
    every sibling script has the same line
  - Good: cutting it, and reporting the copies
  - Bad: leaving a doc's detail on the function because a sibling module
    documents its own that way
  - Good: moving the detail to the code it explains

- Keep a comment you can't explain. Investigate it or ask
  - Bad: cutting `// order matters here` because the order looks arbitrary
  - Good: keeping `// order matters here`

# Guidelines

- Cut a comment only when the code still shows the reader everything the comment
  did
- Judge the whole comment before its clauses. Where a rule cuts every clause,
  delete the comment rather than trimming it
- Keeping one clause protects only that clause. Cut the clauses beside it that a
  rule cuts
- Judge the comment's words. Where keeping a comment requires reading into it
  something it doesn't state, rewrite it to state that, then judge the rewrite.
  Delete it where a rule cuts the rewrite
- Edit comments, not behavior. A rename or an extraction must leave behavior
  unchanged
- Report a bug a comment reveals. Don't fix it silently
