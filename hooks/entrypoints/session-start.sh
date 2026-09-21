#!/bin/sh
# セッションの始めに、残っていることをまとめて伝える

aerie_hooks=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 0
. "$aerie_hooks/lib/common.sh"

aerie_context_rules

found=$(aerie_run_checks)
if [ -n "$found" ]; then
  printf '次のファイルが上限を超えています。作業を始める前に、まずこれを直すか、上限の見直しを利用者に相談してください。\n\n%s\n上限は .aerie/tokens.conf で変えられます。\n\n' "$found"
fi

failed=$(aerie_run_tests)
if [ -n "$failed" ]; then
  printf '次のテストが通りません。そのスクリプトを使う前に直してください。\n\n%s\n' "$failed"
fi

dir=$(aerie_memory_dir 2>/dev/null) || dir=''
if [ -n "$dir" ] && [ -d "$dir" ]; then
  printf 'このブランチの計画と引きつぎです。続きから始めてください。\n\n'
  for f in plan.md handoff.md; do
    [ -f "$dir/$f" ] || continue
    printf '%s\n' "$dir/$f"
    cat "$dir/$f"
    printf '\n'
  done
  if [ -f "$dir/notes.md" ]; then
    printf '気づいたことが残っています。必要なものだけきまりか案件のスキルに直して、branch-memory の clear.sh -f で片づけてください。\n'
  fi
fi

exit 0
