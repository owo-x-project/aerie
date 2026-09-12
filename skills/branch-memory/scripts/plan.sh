#!/bin/sh
# このブランチの計画を書く。本文は標準入力から受けとる
# 行の頭の印は自動でそろえる。済みの印が付いていればそのまま残す

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

dir=$(aerie_memory_dir) || exit 1

body=$(cat)
if [ -z "$body" ]; then
  printf '本文がありません。やることを箇条書きで流しこんでください\n' >&2
  exit 1
fi

out=$(printf '%s\n' "$body" | awk '
  {
    line = $0
    sub(/[ \t]+$/, "", line)
    if (line ~ /^[ \t]*$/) next
    if (match(line, /^[ \t]*([-*+]|[0-9]+[.)])[ \t]+/)) {
      rest = substr(line, RLENGTH + 1)
      mark = " "
      if (match(rest, /^\[[ xX]\][ \t]*/)) {
        m = substr(rest, 2, 1)
        if (m == "x" || m == "X") mark = "x"
        rest = substr(rest, RLENGTH + 1)
      }
      if (rest == "") { printf "!\t%d 行目: 中身がありません\n", NR; bad = 1; next }
      printf "- [%s] %s\n", mark, rest
      next
    }
    printf "!\t%d 行目: %s\n", NR, line
    bad = 1
  }
  END { if (bad) exit 1 }
')

if [ $? -ne 0 ]; then
  printf '計画は一行ひとつの箇条書きにしてください。文章の行は入れません\n' >&2
  printf '%s\n' "$out" | sed -n 's/^!	//p' >&2
  exit 1
fi

aerie_save "$dir" plan.md "$out" || exit 1
