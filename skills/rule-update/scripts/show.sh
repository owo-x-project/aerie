#!/bin/sh
# ルールの中身を見る。効いているほうを出す
# 使い方: show.sh <always|path|tool> <名前>

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

if [ -z "$1" ] || [ -z "$2" ]; then
  printf '使い方: show.sh <always|path|tool> <名前>\n' >&2
  exit 1
fi

file=$(aerie_rule_file "$1" "$2") || exit 1

if [ -f "$aerie_rules_dir/$file" ]; then
  printf '%s\n' "$aerie_rules_dir/$file"
  [ -f "$aerie_rules_builtin/$file" ] && printf '同梱の同じ名前を上書きしています\n'
  printf '\n'
  cat "$aerie_rules_dir/$file"
  exit 0
fi

if [ -f "$aerie_rules_builtin/$file" ]; then
  printf '%s（同梱）\n\n' "$aerie_rules_builtin/$file"
  cat "$aerie_rules_builtin/$file"
  exit 0
fi

printf '%s がありません。list.sh で今あるものを見てください\n' "$file" >&2
exit 1
