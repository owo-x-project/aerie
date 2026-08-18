---
name: owlspec
description: Read and change a project's canonical truth (outcomes, constraints, decisions, designs, verifications, evidence, facts) kept by the owlspec CLI in .owlspec/. Use when the repo contains a .owlspec/ directory, when the user mentions owlspec or canonical records/spec, when asked to record or revise a requirement, decision, design, verification, or evidence, when asked whether an outcome is proven or what evidence exists, when judging whether the recorded spec is sufficient, or when adopting owlspec into an existing project.
---

# Owlspec

## What owlspec is

`.owlspec/records/**` holds the project's **canonical truth** as a typed record graph: what the
project wants to be true (`outcome`), what it must never break (`constraint`), what it chose and why
(`decision`), where that choice landed in the code (`design`), how an outcome is judged
(`verification`), what was observed (`evidence`), and what is asserted (`fact`).

The `owlspec` CLI validates that graph **deterministically and structurally**. It does not, and will
never, judge whether the recorded truth is *semantically sufficient*. **That judgement is yours,
every time.**

## Finding the binary

Run `command -v owlspec`. If it is on PATH, use `owlspec`. If it is not, **ask the user how owlspec
is provided in this project.** Do not guess build paths, do not install it, do not build it from
source unprompted.

Asking is not the same as leaving them stuck. [Troubleshooting](references/troubleshooting.md) has
the install command to offer them, and what to do when the answer is that it should already be
there.

## First moves in a project you don't know

**Start from the path you are about to touch, not from a guessed word.** A repository-relative path
is a legal focus, and it is the one thing you reliably already have:

```bash
owlspec context src/checkout/total.ts
```

That resolves against the paths records declare — a `design.target`, a `verification.target`, a
`source_path` — so it returns what the canonical truth says about that file, including designs whose
target is the *directory* the file lives in. A source document works the same way:
`owlspec context docs/adr/0007-queueing.md` returns the records extracted from it.

Then, in order:

1. `owlspec context <term> [<term>...]` — free text is also a legal focus, matched against record ids
   and titles. **Pass several single distinctive words as separate arguments**, not one phrase: a
   multi-word term matches only as a contiguous substring, so `owlspec context checkout offline`
   finds things that `owlspec context "offline checkout flow"` misses.
2. **If nothing at all resolved, the response tells you what is there.** A call that returns no
   records comes back with an `inventory` — every recorded id and kind — and every id in it
   resolves when you pass it back as a focus. Read it and re-focus; do not start guessing words,
   and do not list `.owlspec/` by hand.

   **An empty inventory is the answer, not a missing one: it means nothing is recorded here**, and
   you may go ahead and record what you could not find. A non-empty one means the opposite — it is
   recorded and you failed to name it, so concluding "not recorded" at that point is how a
   requirement gets written that contradicts one already held. `owlspec check` will not catch that.

   Note that free text is not matched against record bodies, so a word that is central to a record
   but absent from its id and title will miss. That is what the inventory is for.
3. `owlspec status` when the task asks whether something is done or proven. **It lists outcomes
   only.** For the existence of decisions, constraints or facts, the inventory above is the answer.
   `owlspec status --help` names the five states and their precedence; read it once rather than
   inferring what a state means from where it appears.
4. Before your first write of the session, run `owlspec change --schema` (it works even with no
   canonical root) and author against it.

That is the whole cold start: at most three calls before productive work, and zero record files read
by hand.

## What one call gives you back

A slice is the focused records **plus everything one relation hop away in either direction**, plus
the evidence observing any verification in the slice. Direction does not matter, so focusing an
outcome also returns the decisions and designs that point *at* it — not only the verification it
points to.

This is why you should not plan a sequence of calls to walk the graph outwards. Focus the thing you
are working on and read what comes back; call again only when a relation names an id you still need
and did not get.

## The normal loop

```text
owlspec context <terms>            read what is currently true
        ↓
judge sufficiency                  and SAY what you found, in your reply
        ↓
(implement, if the task is code)
        ↓
owlspec change --dry-run --file    confirm acceptance without writing
        ↓
owlspec change --file              commit the semantic change
        ↓
git add .owlspec                   the canonical files are ordinary tracked files
```

A successful `owlspec change` already reports the validation summary of the committed state. **Do not
follow it with `owlspec check`.** `check` is for after merges, after manual edits, and in CI.

Two exit codes, and they mean different things: **1 is a semantic rejection** (the change was
understood and refused — read the diagnostic and fix the content), **2 is "I could not run"** (the
document was unparseable, or a record file on disk is broken). Retrying a 2 with a reworded document
will never help.

## Ground rules

- **Never hand-edit files under `.owlspec/records/**`.** They are inviting Markdown and the instinct
  is to reach for an edit tool. Every write goes through `owlspec change`.
- **Never bulk-read the record files.** `owlspec context` is the sanctioned read: it burns far less
  context and it returns the relation structure, which raw file reads discard.
- **The change document is specified by `owlspec change --schema`, not by this skill.** Field
  requirements, the `op` vocabulary, id rules, and rejection conditions live there. Where this skill
  and the installed binary's schema or diagnostics disagree, **the binary wins.**
- **A passing `check` — or a successful `change` — does not mean the spec is good.** They certify
  structure only.
- **Do not fill a gap with invented certainty.** An unknown becomes a `fact` with
  `confidence = "assumed"`, or a question to the user. Never `known`, and never quietly baked into a
  design body.
- **Do not write a change document from memory, and do not retry a rejection with permutations.**
  Fetch `--schema`; read the diagnostic, which is deterministic and names the violated rule.
- **One intent, one change document.** Do not batch unrelated intents, and do not split one intent.

## Recording that a verification passed

How an observation is recorded depends on the verification's `method`:

| `method` | How to record an observation |
|---|---|
| `automatic` | `owlspec evidence record --verification <id> --result pass --revision <rev>` |
| `manual` | an ordinary `evidence` record, created through `owlspec change` |

Getting this backwards is rejected with a diagnostic naming the command to use instead, so you do not
have to remember the table — but you do have to know why automatic observations are not records.
They live in a regenerable cache, and that has two consequences worth knowing before you trust a
`SATISFIED`:

- **It goes stale on its own.** A new commit, or a change to the verification's `target`, drops a
  recorded pass back to `UNOBSERVED`. Nothing announces this; re-run the check and re-record.
- **It is local.** `owlspec init` keeps the cache out of version control, so CI and a second agent
  will see `UNPROVEN` for an outcome you just proved. That is expected, not a bug: they must run the
  verification themselves.

## Reading a record in order to update it

`update` replaces the record's **entire relation set** and its provenance, not just the fields you
mention. So read it first:

```bash
owlspec context <id> --json
```

The `--json` form carries everything an `update` needs: `body`, the kind-specific fields, the
complete `relations` set, and `source_path` / `source_revision`. The human-readable form does **not**
— it prints one line per record and drops the body — so never build an update from it.

**One field does not round-trip: `title` is derived from the body's first H1 and the change document
rejects it.** Copy the record into your operation, drop `title`, add `op`.

Also note: a `context` slice returns the focused records, and a returned record's relations may point
at ids that are **not in the slice**. That is not an error and not a dangling edge — re-focus on the
missing id before you conclude anything about it.

## When something is already broken

If a record file was hand-edited into an unparseable state, the canonical root will not load at all:
`check`, `fmt` and `change` all abort with the same `fatal: invalid record file ...`. **`change`
cannot repair it** — revert the file with git first. `owlspec fmt` re-canonicalizes files that are
valid but formatted by hand; it is not a repair tool for broken ones.

If `check` reports breakage you did not cause, say so and show the diagnostic rather than papering
over it with a change. Someone else's dangling relation is not yours to silently delete.

## Semantic judgement, condensed

Before you propose or apply any change that alters *meaning* (not just wording), answer these, about
the records you touched and the context slice around them — and **state the answers in your reply to
the user, not just to yourself**:

1. **Name one decision a future implementer would still have to make from this record alone.** If you
   can name it, that is a gap.
2. **Quote the verification that would tell you this outcome had failed** — or state that none
   exists.
3. **State the rejected alternative** for any non-obvious choice. If none is recorded, that is the
   finding.
4. **List every proposition you asserted this session that has no source.** Each becomes a `fact`
   with `confidence = "assumed"`, or a question to the user.

**"No findings; the truth here is sufficient" is a complete and legitimate answer** — but it has to
be said out loud. Inventing findings to look thorough is the same failure as inventing facts.
Findings are *candidates*: they become canonical truth only after the user accepts them and you
record them through `owlspec change`.

## References

Read these on demand; do not preload them.

| File | Read it when |
|---|---|
| [Authoring changes](references/authoring-changes.md) | Before your first change document this session, or when unsure which kind or relation to use |
| [Semantic judgement](references/semantic-judgement.md) | When one of the four questions above surfaces something, when you are asked to review whether the spec is sufficient, or when writing findings up |
| [Adoption](references/adoption.md) | When `.owlspec/` does not exist yet, or when `owlspec migrate` reports uncovered scope |
| [Troubleshooting](references/troubleshooting.md) | When a command fails, when a change is rejected, when `owlspec` is not on `PATH`, or when `status` reports something you did not expect |

## No `.owlspec/` yet?

Adopting a canonical-truth system is the user's decision, not yours. **Ask before running
`owlspec init`.** Then read [Adoption](references/adoption.md).
