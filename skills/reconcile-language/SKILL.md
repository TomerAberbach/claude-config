---
name: reconcile-language
description: |
  Reconcile the domain language in the current commit or a target with the
  project's glossary.md, fixing uses of avoided aliases and proposing glossary
  changes for conflicts and new terms.
argument-hint: '[files, terms, or extra guidance to focus on]'
---

Reconcile the domain language in the target with the project's DDD-style
ubiquitous language glossary. Rewrite the target to use the glossary's terms,
and propose glossary changes for conflicts and new terms, applying them only
after the user confirms.

# Target

```!
jj show --git
```

Arguments: $ARGUMENTS

Reconcile the target named in the arguments if given. Otherwise reconcile the
code and prose changed in the current commit shown above. If there are no
arguments and the commit has no changes, ask the user what to reconcile and
stop.

The glossary is `glossary.md` in the current working directory.

# Principles

- The glossary is the authority until the user changes it. Fix the target to
  match an entry without asking. Change an entry only after the user confirms
- Use one term per concept. Merge two terms for the same concept, and split a
  term that covers two concepts
- Leave homographs alone: words spelled alike whose meanings are unrelated and
  come from different roots or domains. Report a word whose meaning has changed
  within one domain as a conflict
- Collect verbs as well as nouns. A verb like _settle_ is a term when it has a
  domain-specific meaning
- Skip the names of modules, classes, and generic programming constructs unless
  they have a domain-specific meaning
- Stay inside the target. To sweep a term through the whole project, use
  `/rename-concept`

# Workflow

1. Read `glossary.md` if present
2. Read the whole target and collect the domain terms it uses, including terms
   from the conversation that the target relies on. For code, note how to run
   its tests or typecheck
3. Sort every finding into one of these categories:
   - Alias: the target uses a term the glossary lists under aliases to avoid, or
     a synonym for a glossary term. Fix it. For a synonym the glossary doesn't
     list, also propose adding it to the entry's aliases to avoid
   - Conflict: the target uses a glossary term with a different meaning,
     contradicts a definition or relationship, or shows that two glossary
     entries overlap or one entry covers two concepts. Propose a resolution
   - New term: a domain term absent from the glossary. Propose an entry
4. If there is no glossary, every term is new. Skip to step 7 and propose a
   complete glossary in the format under "Glossary format"
5. If there are no findings, tell the user and stop
6. Fix each alias in place, except where the term is also part of a conflict.
   Leave those until the user resolves the conflict:
   - In prose and comments, rewrite the sentence instead of substituting the
     word, because the phrasing around the old term may not fit the new one
   - For an identifier, search the project for references to it. If every
     reference is in the target, rename it and update them all. Otherwise leave
     it and report it as an unfixed alias with a proposal to use
     `/rename-concept`
   - If you renamed an identifier, run the covering tests or a typecheck to
     confirm behavior is unchanged
7. Report (see "Reporting") and wait for the user to confirm, reject, or amend
   each proposal
8. Apply the confirmed proposals:
   - Upsert the entries in `glossary.md`, creating it if absent and following
     "Glossary format". When a term replaces another, list the replaced term
     under aliases to avoid
   - Rewrite the target to match the updated glossary, as in step 6
9. Report what changed

# Proposals

- Conflict: state the glossary entry, the conflicting use with its file and
  line, and the resolution you recommend. Resolutions:
  - Rewrite the target to match the glossary when the glossary is right
  - Update the definition when the domain has changed and the target reflects
    the change
  - Split the entry into two terms when it covers two concepts. Propose a name
    for each
  - Merge entries that describe the same concept. Pick the canonical term and
    list the others under aliases to avoid
- New term: give the full table row (term, definition, aliases to avoid), the
  group it goes under, and any relationships to existing terms. If the target
  uses several names for the new concept, pick one and list the rest as aliases

# Reporting

- Number the proposals in one sequence so the user can confirm each by number.
  List conflicts first, then unfixed aliases, then new terms and unlisted
  synonyms
- Then list the alias fixes already applied, each with the old term, the
  canonical term, and the locations changed

# Glossary format

Follow these rules and the example.

- Keep each definition to one sentence. For an entity, define what it _is_, not
  what it does. **Order** is a request, not "lets customers buy". For an action
  term, define its effect in the domain
- When the terms cluster by subdomain, lifecycle, or actor, give each cluster
  its own heading and table. If all terms belong to one domain, use a single
  table under the top-level heading
- Bold every term name, in tables and in relationships
- End the glossary with a "Relationships" section. State each relationship's
  cardinality, such as "exactly one" or "one or more"

## Example

```md
# Glossary

## Order lifecycle

| Term        | Definition                                              | Aliases to avoid      |
| ----------- | ------------------------------------------------------- | --------------------- |
| **Order**   | A customer's request to purchase one or more items      | Purchase, transaction |
| **Invoice** | A request for payment sent to a customer after delivery | Bill, payment request |

## People

| Term         | Definition                                  | Aliases to avoid       |
| ------------ | ------------------------------------------- | ---------------------- |
| **Customer** | A person or organization that places orders | Client, buyer, account |
| **User**     | An authentication identity in the system    | Login, account         |

## Relationships

- An **Invoice** belongs to exactly one **Customer**
- An **Order** produces one or more **Invoices**
```

# Fixing mistakes

- A test or typecheck fails after a rename: a reference was missed or the name
  is used outside the target. Update the missed references, or restore the
  original name and report it as an unfixed alias
- A fix changed the meaning of a sentence: the old term named a different
  concept than the glossary term. Restore it and report a conflict
