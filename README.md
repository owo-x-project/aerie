# Aerie Workspace Harness

A Composition Root that gives AI CLIs one reproducible way to reach a Project's canonical
truth, its current work, and just enough context — without owning any Project itself.

| Layer | Tool | Answers |
|---|---|---|
| Truth | Owlspec | what is true |
| Work | Beads | what is being done now |
| Cognition | LeanCTX | what has been seen, and what is needed |
| Reasoning | Codex / Claude Code | the actual edits |
| Capabilities | APM | instructions, Skills, hooks, MCP |
| Tools | Nix | the Workspace binaries |
| Repositories | vcs2l | multi-repo composition |
| History | Git | history and sharing |

The design and its rationale live in [workspace-harness-proposal.md](workspace-harness-proposal.md).

## Bootstrap a clone

```bash
nix develop              # the Workspace tools: owlspec, lean-ctx, bd, apm, vcs, codex, claude
lean-ctx trust           # see below — quiet to skip, and it changes behaviour
apm install              # deploy instructions, Skills, hooks and MCP from apm.lock.yaml
bd init --skip-agents    # a fresh work store; the flag matters, see below
```

`nix develop` refuses to start unless every harness tool resolves from `/nix/store`, so a
globally installed binary cannot silently shadow the pinned one. Entering the shell also
extends the LeanCTX shell allowlist with `owlspec`, because LeanCTX otherwise blocks the
Truth layer outright.

### Why `bd init` needs `--skip-agents`

Plain `bd init` writes `AGENTS.md`, creates `CLAUDE.md`, and registers Claude hooks — all
files APM owns — and its generated instructions contradict the harness. `--skip-agents`
creates only the work store. Run `apm audit` if you suspect a tool wrote where APM owns the
file.

`.beads/` is deliberately untracked here: this repository is a template, and a tracked store
would hand every generated Workspace this project's issue history and Beads identity. A
Project that is not a template should track its own `.beads/` so work state is shared.

### Why `lean-ctx trust` is a step

LeanCTX withholds security-sensitive keys from a workspace `.lean-ctx.toml` until the
workspace is trusted, and it does so **quietly** — the harness appears to work while
`rules_injection` is ignored. Trust is also scoped to one directory, which is why the
allowlist entry is applied by the dev shell instead: Projects are where `owlspec` actually
runs, and they are separate workspaces to LeanCTX.

Trust is pinned to the file's contents, so **re-run it after editing `.lean-ctx.toml`**.
Check with `lean-ctx trust status`.

Supported systems are `x86_64-linux`, `aarch64-linux` and `aarch64-darwin`. Owlspec
publishes no Intel-macOS build, and a harness without its Truth layer is not offered.

## Adding a Project

Projects are independent Git repositories under `projects/`, listed in
[workspace.repos](workspace.repos) for vcs2l. Each Project keeps its own environment
manager, toolchain, verification commands, Beads store, and — if it chooses to adopt one —
its own Owlspec canonical root. The Workspace does not reach into any of that, and holds no
Project truth of its own.

Start work from the Project root, not here. The Workspace root is for tasks that genuinely
span repositories.

## Changing the harness

`AGENTS.md`, `.claude/`, `.codex/`, `.agents/` and `.mcp.json` are all generated. Edit the
sources under `.apm/` and regenerate:

```bash
apm install        # dependencies, Skills, hooks, MCP
apm compile        # AGENTS.md from .apm/instructions/
apm audit          # detect a tool writing where APM owns the file
```

Never hand-edit a generated file, and never let another tool's `setup` command write agent
configuration. Beads in particular must be initialized as `bd init --skip-agents`; plain
`bd init` writes `AGENTS.md`, creates `CLAUDE.md`, and registers Claude hooks.
