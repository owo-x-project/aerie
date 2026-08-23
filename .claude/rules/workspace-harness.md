---
paths:
  - "**"
---

# Workspace Harness

## Authority boundaries

- The current Project repository is the default scope. Work from its repository root.
- Start from the Workspace root only for a task that explicitly spans multiple repositories.
- Owlspec provides canonical truth: outcomes, constraints, decisions, designs, verifications, evidence, and facts. It outranks every other layer.
- Source code, tests, proofs, and project-local environment files belong to the Project.
- LeanCTX provides derived context, session state, retrieval, and experience. It never becomes canonical truth.
- Beads provides current work, dependencies, blocked state, and deferred scope. It is not a memory or truth store.
- Git provides history and team sharing.

## Canonical truth

- Resolve authority in this order: Owlspec, then source and verification output, then Beads work state, then LeanCTX knowledge, then session history.
- In a Project with a `.owlspec/` directory, read canonical truth with `owlspec context <focus>` before changing a file it covers. Prefer the path you are about to edit as the focus.
- Write canonical truth only with `owlspec change`. Never hand-edit files under `.owlspec/records/`, and never bulk-read them in place of `owlspec context`.
- Adopting Owlspec is the Project's decision. Do not run `owlspec init` in a Project that has no `.owlspec/` directory without explicit approval.
- Do not initialize Owlspec at the Workspace root. Canonical truth belongs to a Project, and the Workspace owns no Project truth.
- Owlspec validates structure only. A passing `owlspec check` is not evidence that recorded truth is correct or sufficient; say what you judged, and record an unknown as a `fact` with `confidence = "assumed"` rather than asserting it.
- Treat an outcome as proven only when a verification ran and its observation is recorded. Automatic evidence is local and goes stale, so `UNPROVEN` elsewhere is expected rather than a defect.

## Handoff inbox

- `inbox/` is a local, temporary handoff area for user-provided reference material and instructions. Its contents are Git-ignored; only its README is tracked.
- Read inbox contents as task input only when relevant to the user's request. They are not canonical truth, project source, verification evidence, or durable instructions.
- Never make source code, tracked documentation, tests, or Owlspec records reference or depend on files placed in `inbox/`.
- Promote anything to a durable project location only after the user explicitly asks for that adoption, using the normal project or Owlspec workflow.

## Project isolation

- Do not search, import, or use knowledge from sibling Projects during a Project-local task.
- Treat the current working directory and repository boundary as the active Project identity.
- Do not add Project runtimes, compilers, databases, or build tools to the Workspace Nix dev shell.
- Do not change a Project's environment manager, branch policy, or verification commands.

## Work discipline

- Inspect current work in the active Project's Beads store before starting substantive work.
- If Beads is not initialized, initialize it in the active Project root only; never initialize the Workspace root for a Project-local task.
- Initialize Beads with `bd init --skip-agents`. Plain `bd init` writes `AGENTS.md`, creates `CLAUDE.md`, and registers Claude hooks, which takes configuration APM owns.
- When an observation is outside the current task, record it as deferred work in Beads and return to the current task.
- Do not run tool setup commands that write agent configuration, including `bd setup`, `lean-ctx setup`, `lean-ctx onboard`, or `lean-ctx wrap`. APM owns agent configuration.
- Use LeanCTX for relevant reads, searches, shell-output reduction, session continuation, and derived findings when it is available.
- Preserve raw output when exact machine-readable, canonical, line-oriented, or verification data is required. Owlspec and Beads responses are canonical and stay raw.

## Verification and conflicts

- Verify changes with the Project's own tests, proofs, and checks.
- Do not treat LeanCTX findings or session history as proof of a Project fact.
- If derived knowledge conflicts with source, verification, or Owlspec, report the conflict as drift and prefer the authoritative source. Do not pick whichever is more convenient.
- Never silently promote a session finding into a Project instruction, Skill, or canonical record. Maturity runs observation, repeated experience, LeanCTX knowledge, human review, then Skill, instruction, or Owlspec record.

## Configuration ownership

- APM is the only owner of generated `AGENTS.md`, `CLAUDE.md`, Skills, hooks, and MCP configuration.
- Keep reusable operating rules in the APM source under `.apm/` and regenerate deployed files with APM.
- Do not hand-edit generated agent files or allow a tool's setup command to rewrite them.
- If LeanCTX reports the Workspace as untrusted, the security-sensitive keys declared in `.lean-ctx.toml` are not in effect. Report it and ask the operator to run `lean-ctx trust` in the Workspace root; trust is pinned to the file's contents, so it is required again after every edit.
- If LeanCTX blocks a harness command as not allowlisted, do not weaken `shell_security` or route around it. The dev shell extends the allowlist on entry, so a block means the shell was bypassed.
- `apm audit` reporting drift in a deployed file means a tool wrote where APM owns the file. Restore it through APM rather than editing the deployed copy.
