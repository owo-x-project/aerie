#!/bin/sh
# ルールをやめる
# 使い方: drop.sh <always|path|tool> <名前>

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

if [ -z "$1" ] || [ -z "$2" ]; then
  printf '使い方: drop.sh <always|path|tool> <名前>\n' >&2
  exit 1
fi

file=$(aerie_rule_file "$1" "$2") || exit 1

if [ -f "$aerie_rules_dir/$file" ]; then
  rm -f "$aerie_rules_dir/$file" || exit 1
  printf '%s をやめました\n' "$aerie_rules_dir/$file"
  if ! aerie_same_dir && [ -f "$aerie_rules_builtin/$file" ]; then
    printf '同梱に同じ名前があるので、これからは同梱のほうが効きます\n'
  fi
  exit 0
fi

if [ -f "$aerie_rules_builtin/$file" ]; then
  printf 'それは同梱のルールです。ここからは消せません。中身を変えるなら write.sh で同じ名前に書き直してください\n' >&2
  exit 1
fi

printf '%s がありません\n' "$file" >&2
exit 1
