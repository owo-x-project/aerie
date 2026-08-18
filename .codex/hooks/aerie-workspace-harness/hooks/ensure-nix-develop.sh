#!/usr/bin/env bash
set -euo pipefail

# AI CLI PreToolUse hooks run as children of the already-running CLI. They
# cannot replace that parent process's environment, so this hook rewrites the
# pending Bash invocation to run in the workspace's dev shell instead.

input=$(cat)

# When the CLI itself was started from `nix develop`, the shellHook exports
# this marker and no rewrite is needed.
if [[ "${WORKSPACE_HARNESS_ACTIVE:-}" == "1" ]]; then
  exit 0
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Workspace harness requires Nix, but 'nix' is not available on PATH." >&2
  exit 2
fi

workspace=$PWD
while [[ "$workspace" != "/" ]]; do
  if [[ -f "$workspace/flake.nix" && -f "$workspace/apm.yml" ]]; then
    break
  fi
  workspace=$(dirname "$workspace")
done

if [[ ! -f "$workspace/flake.nix" || ! -f "$workspace/apm.yml" ]]; then
  # This hook is intentionally inert outside a workspace-harness project.
  exit 0
fi

# jq is part of the Nix dev shell, not a global dependency. Use the shell to
# parse the event and produce the vendor-native PreToolUse response. Both
# Claude Code and Codex accept this output shape.
rewritten=$(
  printf '%s' "$input" |
    nix develop --no-write-lock-file "path:$workspace" --command jq -c \
      --arg workspace "$workspace" '
        if (.tool_name != "Bash" or (.tool_input.command? | type) != "string") then
          empty
        else
          .tool_input.command as $command
          | if ($command | test("^[[:space:]]*(nix[[:space:]]+develop|exec[[:space:]]+nix[[:space:]]+develop)([[:space:]]|$)")) then
              empty
            else
              .hookSpecificOutput = {
                hookEventName: "PreToolUse",
                permissionDecision: "allow",
                permissionDecisionReason: "Run workspace commands inside nix develop",
                updatedInput: (.tool_input + {
                  command: ("nix develop --no-write-lock-file " + (("path:" + $workspace) | @sh) + " --command bash -lc " + ($command | @sh))
                })
              }
            end
        end
      '
)

if [[ -n "$rewritten" ]]; then
  printf '%s\n' "$rewritten"
fi
