#!/bin/sh
# 今あるルールを並べる

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
. "$aerie_scripts/common.sh"

show() {
  dir=$1
  where=$2
  for f in "$dir"/*.md; do
    [ -f "$f" ] || continue
    base=${f##*/}
    match=$(aerie_rule_match "$f")
    [ -n "$match" ] || match=いつも
    note=$where
    if [ "$where" = 同梱 ] && ! aerie_same_dir && [ -f "$aerie_rules_dir/$base" ]; then
      note='同梱（上書きあり）'
    fi
    printf '%s\t%s\t%s\n' "$base" "$match" "$note"
  done
}

{
  show "$aerie_rules_builtin" 同梱
  aerie_same_dir || show "$aerie_rules_dir" こちら
} | awk -F'\t' '
  { n[NR] = $1; m[NR] = $2; w[NR] = $3; if (length($1) > a) a = length($1) }
  END {
    if (NR == 0) { print "ルールはまだありません"; exit }
    for (i = 1; i <= NR; i++) printf "%-*s  %s  %s\n", a, n[i], m[i], w[i]
  }
'
