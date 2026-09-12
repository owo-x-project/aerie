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

printf 'このブランチの覚え書きが残っています。\n\n%s\n次にも効くことはきまりか案件のスキルに直し、そのうえで branch-memory の clear.sh -f で片づけてから進めてください。\n' "$left" >&2
exit 2
