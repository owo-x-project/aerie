#!/bin/sh
# このブランチの覚え書きを出す
# 使い方: show.sh          ぜんぶ
#         show.sh plan     一つだけ

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

dir=$(aerie_memory_dir) || exit 1

one() {
  file=$1
  title=$2
  [ -f "$dir/$file" ] || return 0
  printf '%s（%s）\n' "$title" "$dir/$file"
  if [ "$file" = plan.md ]; then
    awk '/^- \[[ xX]\] / { printf "%d. %s\n", ++i, substr($0, 3); next } { print }' "$dir/$file"
  else
    cat "$dir/$file"
  fi
  printf '\n'
}

case ${1:-all} in
  plan) one plan.md 計画 ;;
  note|notes) one notes.md 気づき ;;
  handoff) one handoff.md 引きつぎ ;;
  all)
    one plan.md 計画
    one notes.md 気づき
    one handoff.md 引きつぎ
    ;;
  *) printf '使い方: show.sh [plan|notes|handoff]\n' >&2; exit 1 ;;
esac

[ -f "$dir/plan.md" ] || [ -f "$dir/notes.md" ] || [ -f "$dir/handoff.md" ] ||
  printf 'このブランチの覚え書きはまだありません\n'
exit 0
