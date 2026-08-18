---
name: workspace-harness
description: Operate the Workspace Harness with strict Project isolation and Truth/Work/Cognition boundaries.
---

# Workspace Harness workflow

Use this skill for every task started in this Workspace.

1. Establish scope from the current directory. Find the nearest Project repository root before reading sibling directories.
2. For a Project-local task, stay in that repository. Use the Workspace root only when the task explicitly requires multiple repositories.
3. Read canonical truth before changing anything it covers. In a Project with `.owlspec/`, run `owlspec context <path-you-are-about-to-edit>`.
4. Read the active Project's Beads state before changing code. Keep current work, dependencies, blockers, and deferred discoveries in Beads.
5. Use LeanCTX for focused retrieval, compressed shell output, session continuation, and derived findings. Use raw commands for exact verification and canonical machine-readable output.
6. Keep scope tight. Record unrelated improvements as deferred Beads work instead of implementing them immediately.
7. Verify using the Project's own toolchain and checks. Do not add Project-specific dependencies to the Workspace environment.
8. At handoff, leave the current Beads state consistent and save only derived session findings to LeanCTX. Do not promote findings to canonical Project truth automatically.

## Layer boundaries

Owlspec answers what is true, Beads answers what is being worked on now, and LeanCTX answers what has been seen or is needed. Do not use one to do another's job, and do not give any tool authority beyond its layer.

## Owlspec

The `owlspec` binary and the `owlspec` skill ship with this harness; the skill carries the full command surface, so follow it for anything beyond the boundaries below.

- Read with `owlspec context`, write with `owlspec change`. Never hand-edit `.owlspec/records/`.
- Authority runs Owlspec, then source and verification, then Beads, then LeanCTX, then session history. Report a conflict as drift rather than resolving it by preference.
- Adoption is the Project's call. Do not run `owlspec init` unprompted, and never at the Workspace root, which owns no Project truth.
- `owlspec check` certifies structure, not correctness. Judge sufficiency yourself and say what you judged.

## Configuration ownership

APM owns this Skill and all generated agent configuration. Do not run setup commands from Beads, LeanCTX, or Owlspec that modify agent instruction files, hooks, or MCP registration. Initialize Beads with `bd init --skip-agents`; plain `bd init` rewrites `AGENTS.md`, creates `CLAUDE.md`, and registers Claude hooks.
