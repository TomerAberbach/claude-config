---
name: ubiquitize-language
description: |
  Extract a DDD-style ubiquitous language glossary.md file from the current
  conversation and codebase, flagging ambiguities and proposing canonical terms.
argument-hint: '[extra guidance or terms to focus on]'
---

Extract a DDD-style ubiquitous language glossary.md file from the current
conversation and codebase, flagging ambiguities and proposing canonical terms.

$ARGUMENTS

# Workflow

1. Read the `glossary.md` in the current working directory if present
2. Explore the conversation and codebase for domain-relevant terms, including
   actions (a verb like _settle_ is a term defined by what it means in the
   domain)
3. Identify problems:
   - Same term used for different concepts (ambiguity). Exclude homographs: a
     word with unrelated meanings from different roots or domains is fine. Flag
     a word whose meaning has drifted within one domain
   - Different terms used for the same concept (synonyms)
   - Vague or overloaded terms
4. Propose a canonical glossary:
   - When multiple terms exist for the same concept, pick the best one and list
     the others as aliases to avoid
   - Skip the names of modules, classes, and generic programming constructs
     unless they have domain-specific meaning
   - Update an existing definition when the conversation or codebase contradicts
     it
5. Upsert `glossary.md` in the current working directory using the format below
6. Output a summary inline: lead with the problems found, then list the terms
   added or changed

# Output format

`glossary.md`

```md
# Glossary

## Group 1

| Term       | Definition   | Aliases to avoid |
| ---------- | ------------ | ---------------- |
| **Term 1** | Definition 1 | Alias 1, Alias 2 |
| **Term 2** | Definition 2 | Alias 3          |

## Group 2

...

## Relationships

- A **Term 1** belongs to exactly one **Term 2**
- A **Term 2** produces one or more **Term 1s**
```

## Rules

- Keep each definition to one sentence. For an entity, define what it _is_, not
  what it does. **Order** is a request, not "lets customers buy". For an action
  term, define its effect in the domain
- When the terms cluster by subdomain, lifecycle, or actor, give each cluster
  its own heading and table. If all terms belong to one domain, use a single
  table under the top-level heading
- Use bold term names and express cardinality where obvious

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
