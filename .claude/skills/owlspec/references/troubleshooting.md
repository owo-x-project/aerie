# Troubleshooting

Symptoms, what they actually mean, and what to do. Work from the symptom, not from a guess.

**Read the message before acting.** Owlspec's failures name the record, the field, and often the
command to run instead. Most of the entries below are here because the message is easy to skim past,
not because it is missing.

## `owlspec: command not found`

The tool is not on `PATH`. **Do not build it from source, and do not install it silently.** Tell the
user what you found and let them choose one of these.

**Install the released binary.** Works on Linux (x86_64, aarch64) and Apple Silicon macOS. It
downloads the archive, verifies the published checksum, and installs to `~/.local/bin`:

```bash
curl -fsSL https://raw.githubusercontent.com/owo-x-project/owlspec/main/install.sh | sh
```

Pin a version, or install elsewhere:

```bash
curl -fsSL https://raw.githubusercontent.com/owo-x-project/owlspec/main/install.sh \
  | sh -s -- --version 0.2.0 --install-dir /usr/local/bin
```

**Or download it by hand** from https://github.com/owo-x-project/owlspec/releases and put `owlspec`
on `PATH`.

Then confirm with `owlspec --version`.

If the install directory is not on `PATH`, the installer says so and prints the `export` line to
add. A "command not found" immediately after a successful install is almost always that.

Intel macOS and Windows have no published binary. Say so plainly rather than looking for a
workaround.

## `no .owlspec/config.toml found in '<dir>' or any parent directory`

Either this project has no canonical truth yet, or you are running from outside it.

- Check the working directory first. If the canonical root is elsewhere, pass `--path <dir>`.
- If the project genuinely has none, **adopting one is the user's decision.** Ask before running
  `owlspec init`.

## A change was rejected

The exit code tells you which half failed, and they need different fixes.

| Exit | Meaning | What to do |
|---|---|---|
| `2` | The document could not be read at all | A field name, a type, or an `op` is wrong. The message quotes the offending line and lists the fields that are accepted there. Fix the document. |
| `1` | The document was read, and the canonical truth refused it | The content is wrong, not the syntax. Read the diagnostic. |

**On exit 2, read the list of accepted fields in the message.** It is generated from the same
definition the parser uses, so it is exact. `owlspec change --schema` prints the full schema when you
need more than the one field.

A document carries only `operations`. There is no top-level title or intent field.

### Diagnostics you will actually hit

- `dangling_relation_target` and `target_not_found`. The relation or the `target` points at something
  that does not exist. Either you mistyped the id, or you have to create the other record in the
  **same** change. Split changes are how half-connected graphs appear.
- `relation_not_permitted`. That relation type is not legal between those two kinds. The message
  names the pairs that are legal, so read it instead of guessing another type. If none of the legal
  pairs says what you mean, the kinds are probably wrong, not the relation.
- `self_relation`. A record cannot relate to itself.
- `evidence_without_verification`. An `evidence` record has to point at the verification it observed.
- `evidence_for_automatic_verification`. You wrote an evidence record for a verification whose
  method is `automatic`. Nothing reads it, so it is refused rather than silently ignored. Use
  `owlspec evidence record` instead, which writes to the cache the derivation actually consults.
- `source_not_found`. `source_path` names a file that is not there. Provenance that cannot be
  followed back is worse than none.

**Missing required field** rejections name both the record and the field, and requirements differ by
kind. A `fact` needs `confidence`; a `design` needs `target`; a `verification` needs `method` and
`target`. Do not copy a frontmatter block from another kind.

## `owlspec status` says `UNPROVEN` and the checks pass

Passing is not the same as observed. An outcome only reaches `SATISFIED` when the observation was
**recorded**, and running a test does not record anything by itself.

- For a verification with `method = "automatic"`, record the run with `owlspec evidence record`.
- For a `manual` one, the `evidence` record is the observation.
- An outcome with no verification at all is `UNPROVEN` by definition. That is a real finding, not a
  tooling problem: nothing says how you would know it holds.

A single unobserved verification holds the whole outcome at `UNPROVEN`, so check every verification
attached to it, not just the one you just ran.

`owlspec status --help` lists all five states and their precedence. Read it once instead of
inferring a state's meaning from where it appears.

## `owlspec status` says `STALE`

The observation is real but no longer speaks about the current code. What it was observed against
changed after it was recorded. Re-run the verification and record it again.

`STALE` is not a weaker `SATISFIED`. It means nobody has checked the thing as it exists now.

## `owlspec status` says `VIOLATED`

Applicable evidence says a verification failed. This outranks `UNPROVEN` on purpose: one observed
failure is a stronger statement than any number of unobserved checks. Fix the failure or, if the
outcome itself is wrong, change the outcome deliberately through `owlspec change`.

## `owlspec context` returns nothing

The response includes an `inventory` when nothing resolved. Read it before doing anything else.

- **A non-empty inventory means it is recorded and you failed to name it.** Every id in the
  inventory resolves when passed back as a focus. Re-focus; do not conclude "not recorded".
- **An empty inventory is the answer**: nothing is recorded here, and you may record what you could
  not find.

Free text matches ids and titles, not bodies. A word that is central to a record but absent from its
id and title will miss. Pass several distinctive single words as separate arguments rather than one
phrase, and try the file path you are working on.

## `owlspec check` fails after editing records by hand

If the complaint is about formatting rather than content, run `owlspec fmt` and commit the result.
Canonical form is deterministic, so relation order and field order are normalized for you.

`owlspec fmt --check` reports without rewriting, which is the form to use in an automated check.

## A write failed while another one was running

Canonical writes are serialized. If a second write arrives while one holds the lock, it is refused
rather than interleaved. Retry it. If the lock looks stuck with nothing running, a previous run was
killed mid-write; the message names the lock so you can inspect it.

**A change reported as successful has been written.** There is no partially applied change: either
every operation landed or none did. So a failed change does not need cleanup, and you should not
"repair" records after one.

## The version does not match what you expect

`owlspec --version` reports the running binary. If a flag or a field the user mentions does not
exist, check that first: an older binary earlier on `PATH` is a more common cause than a
misunderstanding of the surface.
