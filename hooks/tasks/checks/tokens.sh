#!/bin/sh
# 大きすぎるファイルを見つける
# 引数があればそのファイルだけ、なければ git が持つファイルぜんぶを見る

aerie_hooks=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd) || exit 0
. "$aerie_hooks/lib/common.sh"

conf=$(aerie_config checks/tokens.conf)
[ -f "$conf" ] || exit 0

if [ "$#" -gt 0 ]; then
  for f in "$@"; do
    [ -f "$f" ] && printf '%s\0' "$f"
  done
else
  git ls-files -z 2>/dev/null
fi | xargs -0 wc -lc 2>/dev/null | LC_ALL=C awk -v conf="$conf" '
function glob2re(p,   i, c, r) {
  r = "^"
  for (i = 1; i <= length(p); i++) {
    c = substr(p, i, 1)
    if (c == "*") r = r ".*"
    else if (c == "?") r = r "."
    else if (index(".[]()^$+{}|\\", c) > 0) r = r "\\" c
    else r = r c
  }
  return r "$"
}

# 対象の形に / がなければファイル名だけを見る
function rule_of(path, name,   i) {
  for (i = 1; i <= rules; i++)
    if (byname[i] ? name ~ pat[i] : path ~ pat[i]) return i
  return 0
}

BEGIN {
  rules = 0
  while ((getline line < conf) > 0) {
    sub(/#.*/, "", line)
    gsub(/^[ \t]+|[ \t]+$/, "", line)
    if (line == "") continue
    n = split(line, f, /[ \t]+/)
    if (n < 2) continue
    rules++
    pat[rules] = glob2re(f[1])
    byname[rules] = (index(f[1], "/") == 0)
    lim[rules] = f[2]
    unit[rules] = (n >= 3 ? tolower(f[3]) : "tokens")
  }
  close(conf)
}

NF >= 3 {
  lines = $1 + 0
  bytes = $2 + 0
  path = $0
  sub(/^[ \t]*[0-9]+[ \t]+[0-9]+[ \t]+/, "", path)
  if (path == "total") next
  name = path
  sub(/^.*\//, "", name)
  i = rule_of(path, name)
  if (i == 0 || lim[i] == "-") next
  if (unit[i] == "lines") {
    if (lines > lim[i] + 0) printf "over\t%s\t%d\t%d\tlines\n", path, lines, lim[i]
  } else {
    if (bytes > lim[i] + 0) printf "count\t%s\t%d\n", path, lim[i]
  }
}
' | while IFS='	' read -r kind name value limit unit; do
  if [ "$kind" = "count" ]; then
    limit=$value
    value=$(LC_ALL=C awk -f "$aerie_hooks/lib/count-tokens.awk" "$name" 2>/dev/null) || continue
    [ "$value" -gt "$limit" ] || continue
    unit=tokens
  fi
  printf '%s  %s / %s %s\n' "$name" "$value" "$limit" "$unit"
done
