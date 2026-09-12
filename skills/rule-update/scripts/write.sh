#!/bin/sh
# ルールを作る、または書き直す。本文は標準入力から受けとる
# 使い方: write.sh <always|path|tool> <名前> [合わせる形]

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

kind=$1
name=$2
match=$3

if [ -z "$kind" ] || [ -z "$name" ]; then
  printf '使い方: write.sh <always|path|tool> <名前> [合わせる形]\n' >&2
  exit 1
fi

file=$(aerie_rule_file "$kind" "$name") || exit 1

if [ "$kind" = always ] && [ -n "$match" ]; then
  printf 'always には合わせる形を書きません\n' >&2
  exit 1
fi
if [ "$kind" != always ] && [ -z "$match" ]; then
  printf '%s には合わせる形が要ります。path は *.sh のような形、tool は道具の名前です\n' "$kind" >&2
  exit 1
fi

body=$(cat)
if [ -z "$body" ]; then
  printf '本文がありません。箇条書きを流しこんでください\n' >&2
  exit 1
fi

bad=$(printf '%s\n' "$body" | awk '
  /^[ \t]*$/ { next }
  !/^- / && !/^  / { printf "%d 行目: %s\n", NR, $0 }
')
if [ -n "$bad" ]; then
  printf '本文は箇条書きだけにしてください。見出しや文章は書きません\n%s\n' "$bad" >&2
  exit 1
fi

tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM

{
  printf -- '---\n'
  printf 'name: %s\n' "$name"
  [ -n "$match" ] && printf 'match: %s\n' "$match"
  printf -- '---\n\n'
  printf '%s\n' "$body"
} > "$tmp/$file"

over=$(sh "$aerie_root/hooks/tasks/checks/tokens.sh" "$tmp/$file" 2>/dev/null)
if [ -n "$over" ]; then
  printf 'ルールが長すぎます。短くしてから入れ直してください\n%s\n' "$over" >&2
  exit 1
fi

mkdir -p "$aerie_rules_dir" || exit 1
if [ -f "$aerie_rules_dir/$file" ]; then
  act=書き直しました
else
  act=作りました
fi
cp "$tmp/$file" "$aerie_rules_dir/$file" || exit 1

printf '%s %s\n' "$aerie_rules_dir/$file" "$act"
