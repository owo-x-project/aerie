#!/bin/sh
# このブランチの覚え書きを片づける
# 使い方: clear.sh      中身を出すだけ
#         clear.sh -f   消す

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

dir=$(aerie_memory_dir) || exit 1

if [ ! -d "$dir" ]; then
  printf 'このブランチの覚え書きはありません\n'
  exit 0
fi

if [ "$1" != -f ]; then
  sh "$aerie_scripts/show.sh"
  printf '気づきをきまりか案件のスキルに直してから、clear.sh -f で消してください\n'
  exit 0
fi

rm -rf "$dir" || exit 1
printf '%s を消しました\n' "$dir"
