#!/bin/sh
# 気づいたことを一行足す
# 使い方: note.sh '気づいたこと'

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

dir=$(aerie_memory_dir) || exit 1

if [ "$#" -gt 0 ]; then
  text=$*
else
  text=$(cat)
fi

text=$(printf '%s' "$text" | tr '\n\t' '  ' | sed 's/^[ -]*//; s/  */ /g; s/ *$//')
if [ -z "$text" ]; then
  printf '中身がありません\n' >&2
  exit 1
fi

mkdir -p "$dir" || exit 1
printf -- '- %s %s\n' "$(date +%Y-%m-%d)" "$text" >> "$dir/notes.md"

over=$(sh "$aerie_root/hooks/tasks/checks/tokens.sh" "$dir/notes.md" 2>/dev/null)
printf '%s に足しました\n' "$dir/notes.md"
[ -n "$over" ] && printf '気づきが溜まっています。きまりか案件のスキルに直して、片づけてください\n%s\n' "$over"
exit 0
