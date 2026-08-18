# Authoring changes

> Field-level requirements — which fields each kind reads, the id grammar, the full `op` vocabulary,
> and every rejection condition — live in `owlspec change --schema`. **If this file and the schema
> disagree, the schema wins.** What follows is the part the schema cannot tell you: *which* record to
> write and *how much* to put in one change.

## Choosing a kind by intent

Ask what the sentence you want to record actually is.

| You want to say | Kind | Notes |
|---|---|---|
| "This should be observably true / stay true" | `outcome` | The unit that gets a proven/unproven state. Writable before any code exists. |
| "This must never happen / must always hold" | `constraint` | An invariant that bounds many decisions, not a goal to reach. |
| "We chose X, for these reasons, over these alternatives" | `decision` | **Writable before implementation.** A decision without its rejected alternatives is half a record. |
| "The choice landed here in the tree" | `design` | Points at a real path. **Only exists after implementation** — it is a pointer, not a plan. |
| "This is how you judge whether the outcome holds" | `verification` | Says by what `method` — `automatic` or `manual` — and against what `target`. The method decides how observations get recorded; see the SKILL. |
| "A human observed this, and it cannot be replayed" | `evidence` | Carries the revision it was observed against. **Only for a `manual` verification** — an observation of an `automatic` one goes through `owlspec evidence record`, and writing a record for one is rejected. |
| "This proposition is true" | `fact` | Must declare `confidence`. Use `assumed` for anything you inferred. |

Two distinctions people get wrong:

- **decision vs. design.** A decision is a choice with a rationale and survives refactoring. A design
  is a pointer to where that choice currently lives and dies when the code moves. If you find
  yourself writing prose that explains the code, you wanted a decision, or nothing at all — the code
  is its own description.
- **outcome vs. constraint.** An outcome is something you drive toward and can declare satisfied. A
  constraint is something you never finish; it just must not be violated.

## Choosing a relation

The relation vocabulary is a **closed set**, and which kinds a given relation may join is fixed.
Directions carry meaning, and this graph is what `context` walks and what `status` concludes an
outcome's state from, so a wrong edge is a wrong statement, not a cosmetic slip.

| Relation | Reads as |
|---|---|
| `verified_by` | this outcome is judged by that verification |
| `evidence_for` | this observation speaks to that verification |
| `constrained_by` | this record is bounded by that constraint |
| `motivated_by` | this record exists because of that one |
| `supersedes` | this record replaces that one |
| `relates_to` | a deliberately unprivileged association |

Which record kinds each type may join is **not restated here** — pick the relation whose meaning
matches, send it, and if it is not permitted the rejection names every pair that type does allow.
That list comes from the binary, so it is right even when this file is old.

`relates_to` is the fallback and is legal between any two kinds. Reach for it when no typed relation
states what you mean — **not** to dodge a rejection you did not read.

## Granularity

**One intent, one change document.** A change document is the unit of *meaning*, not of convenience.

- Do not batch unrelated intents to save a call. The document is the record of why these edits belong
  together.
- Do not split one intent across several documents. If a new outcome needs its verification and its
  constraint edge to make sense, they go in the same change — otherwise the canonical graph passes
  through a state that nobody meant.

Operations are **evaluated as a set, not in sequence.** Array order is presentational. Two operations
that conflict on the same id are rejected outright rather than resolved by whichever came last, so
you cannot script a create-then-fix sequence inside one document.

## Naming records

Ids are lowercase ASCII with `.`, `-` and `_`; the exact grammar is in the schema. The **convention**
the schema does not enforce is `<kind>.<area>.<claim>` — `decision.checkout.retry-is-idempotent`,
`outcome.auth.session-survives-restart`. Follow whatever the existing records already do; if the
project has none yet, this shape keeps `owlspec context` free-text matching useful, because the area
word is what people will actually search for.

## `target` and `source_path` are entrances, not bookkeeping

A path a record declares is a focus term. `owlspec context src/checkout/total.ts` returns the
records whose `design.target`, `verification.target` or `source_path` addresses that file — including
a design whose target is the directory the file sits in.

So the precision of a `target` decides whether the next agent finds the record at all. Point a
design at the smallest directory that actually holds the choice, not at the top of the tree: a target
of `src` is technically true and addresses every file in the project, which is the same as addressing
nothing.

## Retiring versus removing

**Retire when the claim stopped being true; remove when the record should never have existed.**

- `retire` keeps the record and its relations, marks it as no longer a claim of the canonical truth,
  and stops it counting toward any outcome's state. History stays legible.
- `remove` deletes it. It is rejected outright if any relation would be left dangling, so removing a
  record that anything points at means editing those records in the same change.

When in doubt, retire. A retired record still answers "what did we used to think", which a deleted
one cannot.

`update` **cannot** flip the retired flag — it carries the existing one forward. Use `retire` /
`unretire`.

## Provenance

`source_path` and `source_revision` record that a record was derived from an existing document, and
they are a **pair** — give both or neither. They are how migration coverage and drift are computed,
so a record derived from a document that has not been committed yet cannot be pinned honestly. See
[Adoption](adoption.md).

## The habit

```bash
owlspec change --schema                        # once per session, before the first write
owlspec change --dry-run --file change.toml    # confirm acceptance, write nothing
owlspec change --file change.toml              # commit
```

The dry run is cheap and the rejection diagnostics are deterministic. When one fires, **read it** — it
names the violated rule and, for relations, the permitted pairs. Do not retry with permutations.
