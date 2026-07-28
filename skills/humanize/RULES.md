# Prose rules

Each rule's Bad and Good differ in one respect: the rule's own. The rules aren't
exhaustive. Cut a tic the rules don't cover when the same reasoning applies.

## Punctuation

- Replace em dashes with a comma, a separate sentence, or a conjunction such as
  "because", "though", or "but". Use the comma only where the dash sets off a
  phrase, because a comma between two full clauses is a splice
  - Bad: "The stage above the parser — the resolver — is cached"
  - Good: "The stage above the parser, the resolver, is cached"
  - Bad: "Retries stop at three — a fourth attempt would exceed the request
    deadline"
  - Bad: "Retries stop at three, a fourth attempt would exceed the request
    deadline"
  - Bad: "Retries stop at three. A fourth attempt would exceed the request
    deadline"
  - Good: "Retries stop at three because a fourth attempt would exceed the
    request deadline"

- Replace most semicolons with two sentences, or with a comma and a conjunction.
  A semicolon joins two full clauses, so a bare comma in its place is a splice
  - Bad: "Counters increment per request; the config sets the batch size"
  - Bad: "Counters increment per request, the config sets the batch size"
  - Good: "Counters increment per request. The config sets the batch size"
  - Good, where both halves are the same shape and the contrast is the point:
    "`request.received` is the handler's count; `request.logged` is the
    middleware's"

## Formatting

- Italicize or bold only when the prose is false without the stress
  - Bad: "The trace records what the client _requested_"
  - Good: "The trace records what the client requested"
  - Good, where the stress marks a contrast: "The schema allows a null, though
    the parser has never _emitted_ one"
  - Good, where the bold is a name or a heading and not stress: "Press
    **Ctrl+C** to stop the run"

## Words and phrases

- Cut intensifiers: actually, simply, just, really, genuinely, in fact, at all,
  etc.
  - Bad: "The dispatcher is simply a lookup table"
  - Good: "The dispatcher is a lookup table"
  - Good, where the word marks a departure from a stated belief: "The plan
    called for two passes; it actually made four"

- Replace a hedge with the condition behind it: almost always, usually,
  generally, typically, tends to, etc. The test: if the reader's next question
  is "when isn't it?", the hedge stands in for a condition you know
  - Bad: "A failed write is almost always safe to retry"
  - Good: "A failed write is safe to retry unless it already returned a 2xx"
  - Good, where the condition is obvious or a tangent: "The first request after
    a deploy usually takes a second longer"

- Don't give a thing intent, desire, knowledge, perception, emotion, or a life
  of its own. The test: would a spec use this verb of this thing? Specs say "the
  parser requires"; none says "the parser wants"
  - Bad: "The parser wants a trailing newline"
  - Good: "The parser requires a trailing newline"
  - Bad: "A fixture has to say what happened"
  - Good: "A fixture records what happened"
  - Bad: "The record names the evicted key"
  - Good: "The record contains the evicted key"
  - Bad: "The token lives in the config file"
  - Good: "The token is stored in the config file"
  - Swaps: wants → requires, knows → records, decides → selects, sees →
    receives, says or names → contains or records, gives → provides, struggles
    with → fails on, lives in → is stored in, belongs in → must be in, sits
    above → is above, travels with → is included in, etc.
  - Good, where the verb is the thing's own operation: "The scheduler retries
    the job"

- Replace an imported metaphor with the plain term for the thing itself. The
  test: would this word appear in a spec, or only in a blog post?
  - Bad: "The seam between parsing and evaluation"
  - Good: "The boundary between parsing and evaluation"
  - Bad: "This call is load-bearing"
  - Good: "This call is required"
  - Swaps: surface area → the exposed API, blast radius → the scope of a
    failure, north star → the goal, table stakes → the minimum, first-class →
    fully supported, etc.
  - Good, where the metaphor is the domain's own term: "The socket closes when
    the stream ends"

- Prefer the short common word when the long one adds no precision
  - Bad: "Leverage the cache for repeat lookups"
  - Good: "Use the cache for repeat lookups"
  - Bad: "The report surfaces the warnings"
  - Good: "The report shows the warnings"
  - Swaps: utilize → use, facilitate → help, myriad → many, unpack → explain,
    prior to → before, etc.
  - Good, where the long word is the precise one: "Make the handler idempotent"

- Replace a negated verb with the positive verb that means the same thing
  - Bad: "The schema does not allow a null"
  - Good: "The schema forbids a null"
  - Swaps: does not include → excludes, does not have → lacks, is not able to →
    cannot, is not the same as → differs from, does not continue → stops, etc.
  - Good, where no single verb replaces the negation: "The parser does not
    retry"

- Replace two negations that cancel with the positive they add up to. The
  shapes: a negative subject with a negated clause, and a negated negative word
  - Bad: "Nothing is logged that isn't journaled"
  - Good: "Everything logged is journaled"
  - Bad: "A retry is not uncommon after a deploy"
  - Good: "A retry is common after a deploy"
  - Good, where a third state stops the negations from canceling: "The flag is
    not disabled" when it may also be unset

- Replace a vague verb or an abstract subject with the specific thing
  - Bad: "The middleware handles the auth header"
  - Good: "The middleware verifies the auth header"
  - Bad: "The step processes each row"
  - Good: "The step compresses each row"
  - Bad: "Reality has diverged from the cached offset"
  - Good: "The stream has moved past the cached offset"

- Treat these words as suspect, in any form: load-bearing, seam, carry, survive,
  provenance, owe, land, drive, clean. Swap in a plain and concrete candidate
  unless the word is the domain's own term for the thing
  - Bad: "git status is clean"
  - Good: "git status show no changed files"
  - Bad: "The record carries the evicted key"
  - Good: "The record contains the evicted key"
  - Good, where the domain uses the word: "The header carries the trace ID from
    service to service"

- Spell out a coined compound adjective the reader can't understand on first
  read
  - Bad: "Cache-miss-triggered refreshes run on the worker"
  - Good: "A refresh triggered by a cache miss runs on the worker"
  - Good, where the compound is standard in the domain: "the write-ahead log"

- Repeat the word you used for a thing or an action. A synonym makes the reader
  check whether it names a second thing. The test: if swapping one word for the
  other needs the sentence rewritten, they weren't interchangeable and this rule
  doesn't apply
  - Bad: "The alert waits until the failure looks real. … If the failure is
    genuine, the alert goes out"
  - Good: "The alert waits until the failure is confirmed. … If the failure is
    confirmed, the alert goes out"
  - Bad: "An `update` event may arrive with no session ID. … The event before it
    is the bare one"
  - Good: "An `update` event may arrive with no session ID. … The event before
    it is the one with no session ID"
  - Good, where the swap needs a rewrite: "Cut the trailing clause" and "Trim
    the list to two items"

- Reserve superlatives for claims that are exclusive and checkable
  - Bad: "`cache.miss` is the most useful record for finding an evicted key"
  - Good: "`cache.miss` is the only record that contains the evicted key"
  - Bad: "A wall-clock log is useless on the runs most worth debugging"
  - Good: "A wall-clock log is useless on the runs that fail intermittently"

- Don't frame a fact as "the one X that Y" or as "nothing else Y". Drop the
  exclusivity where the reader doesn't need to know that nothing else qualifies,
  and say it with "only" where they do
  - Bad: "Nothing else drains the queue"
  - Good: "Only the scheduler drains the queue"
  - Bad: "Eviction is the one thing the cache defers"
  - Bad: "The cache defers only eviction"
  - Good: "The cache defers eviction"
  - Bad: "A timeout is the one way out of the retry loop"
  - Good: "Only a timeout leaves the retry loop"
  - Bad: "The request body is the one thing the log can't reconstruct"
  - Good: "The log reconstructs everything but the request body"

- Give a list as many items as it has. Don't pad it to three for rhythm with a
  restatement of an earlier item or a term that adds nothing
  - Bad: "The format is simple, portable, and easy to read"
  - Good: "The format is simple and portable"
  - Bad: "Retries are capped, logged, and accounted for"
  - Good: "Retries are capped and logged"
  - Good, where every item adds something: "The record contains a timestamp, a
    level, and a message"

- Cut a count the reader can get from the list beside it, and the "both" or
  "all" that follows one
  - Bad: "The two required headers, `Accept` and `Host`, are both validated"
  - Good: "The required headers, `Accept` and `Host`, are validated"
  - Bad: "There are three reserved fields: id, ts, and level"
  - Good: "The reserved fields are id, ts, and level"
  - Good, where the count is the claim: "A quorum needs three of the five nodes"

- Give a number only where it's counted. The test: if another number would
  change nothing, the number is emphasis. Replace it with the plain quantity
  - Bad: "Twenty small timeouts will exhaust the retry budget"
  - Good: "Enough small timeouts will exhaust the retry budget"
  - Bad: "A hundred callers depend on the default timeout"
  - Good: "Many callers depend on the default timeout"
  - Good, where the number is counted: "The retry budget allows three attempts"

- Name a list's members only when the reader needs those members. Otherwise name
  the class, which won't need updating as the class grows
  - Bad: "The stages above the parser, resolver and executor, are cached"
  - Good: "The stages above the parser are cached"
  - Bad: "Indexing, compaction, and backfill report progress"
  - Good: "Long-running jobs report progress"
  - Good, where the reader needs the members: "Only id, ts, and level are
    reserved"

## Sentences

- Use the active voice or an imperative. Keep the passive where the actor is
  unknown, or where naming it would add a noun the sentence doesn't need
  - Bad: "The original error must be recorded"
  - Good: "The trace records the original error"
  - Bad: "Retries should be capped at three"
  - Good: "Cap retries at three"
  - Bad: "The evicted key is written to the log"
  - Good: "The cache logs the evicted key"
  - Good, where the actor adds nothing: "The stages above the parser are cached"

- Write a requirement as an instruction. Stated as a fact, a requirement leaves
  the reader to work out the action
  - Bad: "A retry past the deadline is a bug"
  - Good: "Stop retrying at the deadline"
  - Bad: "A handler without a timeout is invalid"
  - Good: "Give every handler a timeout"
  - Good, where the sentence describes behavior instead of requiring it: "The
    parser stops at the first error"

- Don't support a claim with what "you" or "anyone" would do with the thing, and
  don't cast a component as "we" or "us". Keep the thing in the subject slot
  - Bad: "The events are still logged, so you can watch the queue before you
    have a consumer"
  - Good: "The events are still logged, so the log shows the queue before a
    consumer exists"
  - Bad: "The service is refusing us"
  - Good: "The service is refusing the client"
  - Good, where the instruction is to the reader: "Copy the example config
    before you start"

- Replace a "which" whose antecedent is the whole preceding clause with a
  conjunction or a new sentence
  - Bad: "Thumbnails are the client's job, which keeps the extra network calls
    off the request path"
  - Good: "Thumbnails are the client's job, so the extra network calls stay off
    the request path"
  - Good, where "which" modifies a noun: "The queue drains on a background task,
    which retries with backoff"

- Break out a parenthesis that holds a full clause. A phrase can stay
  - Bad: "Cached medians fill the missing timeouts (the first request is never
    measured: a cold connection inflates it)"
  - Good: "Cached medians fill the missing timeouts. The first request is never
    measured, because a cold connection inflates it"
  - Good, where the parenthesis is a phrase: "the noise floor (learned only
    while idle)"

- Split a sentence that states more than one claim. The shapes: a reason that
  has its own reason, a consequence that has its own consequence, and a claim
  followed by cases that each add an aside. The test: state the claim in one
  clause, and every fact left over is another sentence
  - Bad: "The cache is keyed on the path because query strings vary per client,
    and they vary because each client appends its own trace ID"
  - Good: "The cache is keyed on the path because query strings vary per client.
    They vary because each client appends its own trace ID"
  - Bad: "Each stage reports progress differently: the parser counts rows (one
    line per file), the resolver counts symbols (one line per module), and the
    executor counts nothing"
  - Good: "Each stage reports progress differently. The parser counts rows (one
    line per file). The resolver counts symbols (one line per module). The
    executor counts nothing"
  - Good, where the sentence states one claim and its reason: "Retries stop at
    three because a fourth attempt would exceed the request deadline"

- Join two sentences with a conjunction when their relation is a cause or a
  contrast. Don't leave the relation for the reader to infer from the order
  alone
  - Bad: "The cache is keyed on the path. Query strings vary per client"
  - Good: "The cache is keyed on the path because query strings vary per client"
  - Good, where the sentences are merely sequential: "Counters increment per
    request. The config sets the batch size"

- Cut what the reader can supply: the consequence of a stated fact, or the
  reason for an instruction they would have followed anyway. In a chain of
  consequences, keep the fact and the case it decides, and cut the steps between
  - Bad: "The cache is keyed on the path, so two clients share an entry, so a
    per-client header must not change the response"
  - Good: "The cache is keyed on the path. A per-client header must not change
    the response"
  - Bad: "Each row contains its own schema version, so a parser needs no side
    table"
  - Good: "Each row contains its own schema version"
  - Bad: "Log the original error at the call site. A dropped request leaves no
    other trace of it"
  - Good: "Log the original error at the call site"
  - Good, where the addition is news: "Each device stores its own token, so
    revoking one seat leaves the others signed in"

- State a claim once. Cut a phrase or sentence that restates one beside it
  - Bad: "The client retries automatically, with nothing to configure"
  - Good: "The client retries automatically"
  - Bad: "The cache refreshes twice a day. It re-fetches entries every 12 hours"
  - Good: "The cache refreshes every 12 hours"

- Trim "X, not Y" to "X" if the reader would not think of "Y" on their own, and
  keep at most one "not Y" in a sentence
  - Bad: "Buckets keep the maximum, not the average"
  - Good: "Buckets keep the maximum"
  - Bad: "Write `retries=3`, not `3 retries`, and put it in the section header,
    not the body"
  - Good: "Write `retries=3`, not `3 retries`, and put it in the section header"
  - Good, where Y is what a writer would otherwise have done: "Write
    `retries=3`, not `3 retries`"

- Don't define a thing by what it isn't. Where the reader could confuse two
  things, define both
  - Bad: "Not a metric: a record is an event"
  - Bad: "A record is an event, not a metric"
  - Good: "A record is an event"
  - Bad: "A sink receives records, not requests"
  - Good: "A sink receives records. A handler receives requests"

- State what a thing does before what it doesn't do. Where the reader expects
  the other behavior, name it in a trailing clause
  - Bad: "The parser does not fail, but it silently produces wrong output"
  - Good: "The parser silently produces wrong output instead of failing"
  - Bad: "The retry does not stop at the deadline, but it runs until the socket
    closes"
  - Good: "The retry runs until the socket closes instead of stopping at the
    deadline"

- State a tradeoff as the decision and its consequence, not as a maxim. The
  test: if the main clause ranks two options against each other, rather than
  stating the decision, it's a maxim. The ranking can use any comparison: "X is
  worse than Y", "X beats Y", "X is cheap next to Y"
  - Bad: "A counter is cheap next to a trace, so tracing is opt-in"
  - Good: "Record a trace only when the request sets the debug flag, so the
    common path stores only a counter"
  - Bad: "A stale entry beats a slow lookup"
  - Good: "Serve the stale entry, so the lookup never waits on the refresh"
  - Bad: "A dropped log line is worse than a slow handler"
  - Good: "Flush the line before the handler returns, so a crash never drops it"
  - Bad: "Logging a false error beats missing a real one"
  - Good: "Log the error even when the request may have succeeded, and accept
    the false lines"

## Paragraphs

- Cut a paragraph's last sentence when it comments on the paragraph rather than
  continuing it. If the comment is worth keeping, it belongs in the topic
  sentence
  - Bad: "…and the log keeps every branch the resolver took. That is the point:
    those are the failures that never reproduce on a second run"
  - Good: "…and the log keeps every branch the resolver took"
  - Good, with the comment in the topic sentence: "The log keeps every branch
    the resolver took, for the failures that never reproduce on a second run. …"

- When several sentences in a row attach a consequence with "so", "therefore",
  "thus", or "hence", keep one and recast the others
  - Bad: "The totals are per request, so the report is complete. Sampling
    matches the old cadence, so the output is unchanged"
  - Good: "The totals are per request, so the report is complete. Because
    sampling matches the old cadence, the output is unchanged"

# Guidelines

- Don't change meaning. When cutting would lose a claim, keep it
- Keep code blocks, links, and markup intact. Never edit code or identifiers.
  Comments and docstrings are prose
