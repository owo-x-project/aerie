#!/bin/sh
# マージやプルリクの前に、片づけていない覚え書きがないか見る

aerie_hooks=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 0
. "$aerie_hooks/lib/common.sh"

cmd=$(awk '
  match($0, /"command"[ \t]*:[ \t]*"([^"\\]|\\.)*"/) {
    s = substr($0, RSTART, RLENGTH)
    sub(/^"command"[ \t]*:[ \t]*"/, "", s)
    sub(/"$/, "", s)
    gsub(/\\"/, "\"", s)
    gsub(/\\n/, " ", s)
    gsub(/\\\\/, "\\", s)
    print s
    exit
  }
')
[ -n "$cmd" ] || exit 0

risk=$(aerie_risk_of "$cmd")
if [ -n "$risk" ]; then
  case $(aerie_stage_action risk) in
    warn)
      printf '危険な操作です（%s）。初期段階では止めませんが、対象を確認してください。\n' "$risk" >&2
      ;;
    block)
      printf '危険な操作のため止めました（%s）。運用段階では対象と許可を確認してから進めてください。\n' "$risk" >&2
      exit 2
      ;;
  esac
fi

case "$cmd" in
  *"--abort"*|*"--continue"*|*"--quit"*) exit 0 ;;
  *"git merge"*|*"gh pr create"*|*"gh pr merge"*) ;;
  *) exit 0 ;;
esac

dir=$(aerie_memory_dir 2>/dev/null) || exit 0
[ -n "$dir" ] && [ -d "$dir" ] || exit 0

left=''
for f in plan.md notes.md handoff.md; do
[ -f "$dir/$f" ] && left="$left$dir/$f
"
done
[ -n "$left" ] || exit 0

case $(aerie_stage_action memory) in
  warn)
    printf 'このブランチの覚え書きが残っていますが、初期段階なので止めません。必要ならきまりか案件のスキルに直して片づけてください。\n%s' "$left" >&2
    exit 0
    ;;
  *)
    printf 'このブランチの覚え書きが残っています。きまりか案件のスキルに直し、branch-memory の clear.sh -f で片づけてから進めてください。\n%s' "$left" >&2
    exit 2
    ;;
esac
