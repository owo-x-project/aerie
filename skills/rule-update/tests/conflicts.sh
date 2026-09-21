#!/bin/sh
# rule-update の重なり検出を試す

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/../../.." && pwd)
. "$root/hooks/lib/test.sh"

tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM
export AERIE_RULES_DIR="$tmp/rules"

aerie_ok '一つ目を作る' sh -c "printf -- '- 一つ目\n' | sh '$root/skills/rule-update/scripts/write.sh' path first '*.md' '一つ目の対象'"
aerie_ok '二つ目を作る' sh -c "printf -- '- 二つ目\n' | sh '$root/skills/rule-update/scripts/write.sh' path second '*.md' '二つ目の対象'"
got=$(sh "$root/skills/rule-update/scripts/conflicts.sh")
aerie_has '同じ範囲を知らせる' '同じ範囲のきまりです' "$got"
aerie_has '一つ目を出す' 'path-first.md' "$got"
aerie_has '二つ目を出す' 'path-second.md' "$got"

aerie_test_end
