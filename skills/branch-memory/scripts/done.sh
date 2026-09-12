#!/bin/sh
# 計画の項目に済みの印を付ける
# 使い方: done.sh 1 3    -u を先に付けると印を外す

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

dir=$(aerie_memory_dir) || exit 1
plan="$dir/plan.md"

mark=x
if [ "$1" = -u ]; then
  mark=' '
  shift
fi

if [ "$#" -eq 0 ]; then
  printf '使い方: done.sh 1 3    -u を先に付けると印を外す\n' >&2
  exit 1
fi

if [ ! -f "$plan" ]; then
  printf '計画がまだありません。plan.sh で作ってください\n' >&2
  exit 1
fi

nums=$*
tmp=$(mktemp) || exit 1
trap 'rm -f "$tmp"' EXIT INT TERM

LC_ALL=C awk -v nums="$nums" -v mark="$mark" '
  BEGIN { n = split(nums, a, /[ \t,]+/); for (i = 1; i <= n; i++) want[a[i] + 0] = 1 }
  /^- \[[ xX]\] / {
    item++
    if (want[item]) { hit[item] = 1; printf "- [%s] %s\n", mark, substr($0, 7); next }
  }
  { print }
  END {
    for (i = 1; i <= n; i++) if (!hit[a[i] + 0]) printf "!\t%s 番はありません\n", a[i]
  }
' "$plan" > "$tmp" || exit 1

miss=$(sed -n 's/^!	//p' "$tmp")
sed '/^!	/d' "$tmp" > "$plan"

sh "$aerie_scripts/show.sh" plan
[ -n "$miss" ] && printf '%s\n' "$miss" >&2
exit 0
