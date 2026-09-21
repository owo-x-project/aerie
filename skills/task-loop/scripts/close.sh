#!/bin/sh
# 作業の最後に、実装物を正本として検査する

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
aerie_root=$(CDPATH= cd -- "$aerie_scripts/../../.." && pwd) || exit 1
aerie_hooks="$aerie_root/hooks"
. "$aerie_hooks/lib/common.sh"

failed=0

# AGENTS.md は利用者の作業場所の指示を含むため、既存の空行変更は触らない。
if ! git diff --check -- . ':(exclude)AGENTS.md' >/dev/null 2>&1; then
  printf '差分の空白を直してから再検査してください\n' >&2
  failed=1
fi

found=$(aerie_run_checks)
if [ -n "$found" ]; then
  case $(aerie_stage_action edit) in
    warn) printf '%s\n' "$found" >&2 ;;
    *)
      printf '%s\n上限を超えたファイルを直してから再検査してください\n' "$found" >&2
      failed=1
      ;;
  esac
fi

tests=$(aerie_run_tests)
if [ -n "$tests" ]; then
  printf '%s\n試験が通ってから完了してください\n' "$tests" >&2
  failed=1
fi

[ "$failed" -eq 0 ] || exit 2
printf '作業の検査が通りました\n'
