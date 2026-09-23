#!/bin/sh
# 大きさの検査を試す

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/.." && pwd)
. "$root/lib/test.sh"

check="$root/tasks/checks/tokens.sh"
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM

project="$tmp/project"
mkdir -p "$project/.aerie" "$tmp/深い/ところ"
cat > "$project/.aerie/tokens.conf" <<'CONF'
# 同梱の上限に加えて、プロジェクト固有の除外を指定する
addons/godot_mcp/** -
CONF
awk 'BEGIN{for(i=0;i<300;i++)print "- あいうえおかきくけこ"}' > "$tmp/深い/ところ/always-big.md"
printf -- '- みじかい\n' > "$tmp/always-small.md"
awk 'BEGIN{for(i=0;i<900;i++)print "x"}' > "$tmp/深い/ところ/big.txt"
printf 'ちいさい\n' > "$tmp/small.png"

got=$(cd "$project" && sh "$check" "$tmp/深い/ところ/always-big.md" 2>&1)
aerie_has '名前だけの形が深いところでも当たる' 'always-big.md' "$got"
aerie_has '上限が出る' '400 tokens' "$got"

got=$(cd "$project" && sh "$check" "$tmp/always-small.md" 2>&1)
aerie_eq 'みじかいものは出ない' '' "$got"

got=$(cd "$project" && sh "$check" "$tmp/深い/ところ/big.txt" 2>&1)
aerie_has '行数で見るもの' 'lines' "$got"

got=$(cd "$project" && sh "$check" "$tmp/small.png" 2>&1)
aerie_eq '見ないものは出ない' '' "$got"

got=$(cd "$project" && sh "$check" "$tmp/ないファイル.md" 2>&1)
aerie_eq 'ないファイルでも静か' '' "$got"

aerie_test_end
