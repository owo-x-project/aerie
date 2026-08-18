# Adoption

Read this when `.owlspec/` does not exist yet, or when `owlspec migrate` reports uncovered scope.
The SKILL already says to ask the user before running `owlspec init`; the reason is that a canonical
root nobody agreed to maintain becomes a directory that rots.

## Greenfield

```bash
owlspec init
```

Then seed with the records that are writable **before** any code exists:

1. `outcome` — what the project wants to be observably true.
2. `constraint` — what it must never break.
3. `decision` — the choices already made, each with its rejected alternative.

Do not seed `design` records. A design points at where a decision landed in the tree; before the code
exists there is nothing to point at, and a design written in advance is a plan wearing the wrong
label. Add them as implementation happens.

## Brownfield: adopting into a project that already has documents

Non-destructive here does **not** mean copying every byte into `.owlspec/`. It means:

> the original project is left intact, and every adopted record can be traced back to the source
> document and the revision it was read at.

Git remains the authority for original content and history. Owlspec does not archive source bytes.

### The flow

```text
branch or worktree
  → commit the source documents           (see the trap below — this step is load-bearing)
  → set the scope
  → read and extract candidates
  → attach provenance
  → user reviews
  → owlspec change --dry-run          (the deterministic check happens before acceptance)
  → accept through an ordinary `owlspec change`
  → owlspec migrate
```

### Set the scope

The scope is declared in `.owlspec/config.toml`. **The exact key and its shape are printed by
`owlspec migrate --help`** — read them there rather than from this file, which does not move when the
binary does. While no scope is declared, `owlspec migrate` says so instead of reporting coverage.

Scope is what `owlspec migrate` measures coverage against. **Keep it to documents that actually state
requirements, decisions, or constraints.** Pointing it at a whole docs tree produces a permanent list
of tutorial pages reported as uncovered, and a report nobody can ever finish is a report nobody
reads.

Never let secrets, credentials, or untracked scratch files become records. Records are canonical and
are meant to be committed.

### Extract by reading, not by transcribing

Candidates come from **reading a document and deciding what claim it is making.** A heading is not a
requirement; a paragraph may contain three decisions or none. Mechanically converting headings into
records produces a graph that validates cleanly and says nothing.

A candidate is not truth. Do not build a candidate directory, a proposal database, or a migration
journal alongside the canonical records — candidates live in your response to the user until they are
accepted, and then they enter through `owlspec change` like any other change.

### Attach provenance

```toml
source_path = "docs/adr/0003-queueing.md"
source_revision = "<the commit the document was read at>"
```

Both or neither. They are what coverage and drift are computed from.

> **The trap: commit the source documents first.**
>
> Drift is computed against the **working tree**, not against `HEAD`. If you canonicalize a document
> that has uncommitted edits, there is no revision you can honestly pin, and the record is reported
> as outdated from the moment it is created — with no action available that clears it.
>
> There is a related consequence during ongoing work: when you change a source document and its
> record in the same change, that record shows as outdated until the change is committed and the
> revision is re-pinned. That is expected, not a defect.

### Re-pinning is a separate step, on purpose

A pin can only name a revision that exists. So a change that touches a source document and its
record together **cannot** pin correctly inside itself — the commit it would name has not happened
yet. Commit first, then re-pin the affected records and commit that, or leave the drift and know why
it is there. Either is honest; silently pinning to the previous revision is not.

### Adopt progressively

Partial adoption is a first-class state, not an unfinished one. Take one domain area at a time and
leave the rest uncovered. Coverage is reported by `owlspec migrate` and is deliberately **not** a
`owlspec check` diagnostic: an incompletely adopted project is not a broken project, and making it an
error would force teams to adopt everything at once or turn the check off.

## Make the next agent's life easier

Once `.owlspec/` exists, offer to add one line to whatever file this project already uses to give its
agents standing instructions:

```markdown
Canonical truth lives in `.owlspec/`. Read it with `owlspec context`, change it with `owlspec change`.
```

Ask which file that is; do not invent one, and do not assume the file your own harness happens to
read is the one this project keeps.

This matters more than it looks. Users say "update the requirement" without ever naming owlspec, and
without that line the next agent will not know the canonical records exist and will edit prose
somewhere else instead.
