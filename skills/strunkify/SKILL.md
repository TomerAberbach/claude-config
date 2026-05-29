---
name: strunkify
description:
  Make prose terse and tight in the style of The Elements of Style by Strunk &
  White.
disable-model-invocation: true
---

Make the given prose terse and tight in the style of The Elements of Style by
Strunk & White.

$ARGUMENTS

# Workflow

1. Identify the target text:
   - A file path or text in `$ARGUMENTS`
   - Otherwise, the most recent prose under discussion in the conversation
   - If neither exists, ask the user what to strunkify and stop
2. If the text is already tight, tell the user and stop
3. Apply the passes in "Passes" to the text
4. For a file, edit it in place. Otherwise, output the revised text
5. Report the word count before and after

# Passes

1. Omit needless words
   - "the fact that" -> "because" or delete
   - "in order to" -> "to"
   - "there is/are ... that/which" -> restructure around the real subject
   - "is able to" -> "can"
   - Delete throat-clearing openers: "It is worth noting that", "Basically",
     "Essentially", "In general"
   - Cut redundant pairs: "each and every", "first and foremost"
2. Use the active voice: "the system was tested by us" -> "we tested the
   system". Keep passive only when the actor is unknown or irrelevant
3. Put statements in positive form: "not honest" -> "dishonest", "did not
   remember" -> "forgot"
4. Use definite, specific, concrete language. Replace abstractions and hedges
   ("somewhat", "quite", "very") with the plain claim or a concrete detail
5. Make one paragraph serve one topic. Lead with the topic sentence
6. Use parallel structure for parallel ideas, in lists and in series
7. Place the emphatic words of a sentence at the end
8. Prefer short Anglo-Saxon words over long Latinate ones, unless the long word
   is a term of art: "utilize" -> "use", "commence" -> "start"
9. Replace em dashes with commas, semicolons, or separate sentences

These aren't exhaustive. Reason from first principles when none fits cleanly.

# Guidelines

- Don't change meaning. When cutting would lose a real claim, keep it
- Preserve the author's voice and any technical terms; tighten, don't rewrite
  into a different register
- Preserve formatting: code blocks, links, and markup stay intact; never edit
  code or identifiers. Comments and docstrings are prose
