#!/bin/sh
# このブランチの引きつぎを書く。本文は標準入力から受けとる

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

dir=$(aerie_memory_dir) || exit 1

body=$(cat)
if [ -z "$body" ]; then
  printf '本文がありません。箇条書きで流しこんでください\n' >&2
  exit 1
fi

bad=$(printf '%s\n' "$body" | awk '
  /^[ \t]*$/ { next }
  !/^- / && !/^  / { printf "%d 行目: %s\n", NR, $0 }
')
if [ -n "$bad" ]; then
  printf '引きつぎは箇条書きだけにしてください\n%s\n' "$bad" >&2
  exit 1
fi

aerie_save "$dir" handoff.md "$body" || exit 1
