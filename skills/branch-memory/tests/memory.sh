#!/bin/sh
# branch-memory のスクリプトを試す

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/../../.." && pwd)
. "$root/hooks/lib/test.sh"

s="$here/../scripts"
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM
export AERIE_MEMORY_DIR="$tmp"

aerie_ok '計画を書く' sh -c "printf -- '- ひとつめ\n* [x] ふたつめ\n1. みっつめ\n' | sh '$s/plan.sh'"

got=$(sh "$s/show.sh" plan 2>&1)
aerie_has '番号' '1. [ ] ひとつめ' "$got"
aerie_has '済みは残る' '2. [x] ふたつめ' "$got"
aerie_has '数字の行' '3. [ ] みっつめ' "$got"

aerie_fails '文章の計画' sh -c "printf 'これは文章\n' | sh '$s/plan.sh'"
aerie_fails '中身なしの計画' sh -c ": | sh '$s/plan.sh'"

aerie_ok '済みにする' sh "$s/done.sh" 1
got=$(sh "$s/show.sh" plan 2>&1)
aerie_has '印が付く' '1. [x] ひとつめ' "$got"

aerie_ok '印を外す' sh "$s/done.sh" -u 2
got=$(sh "$s/show.sh" plan 2>&1)
aerie_has '印が外れる' '2. [ ] ふたつめ' "$got"

aerie_ok '気づきを足す' sh "$s/note.sh" 'ひとつめの気づき'
aerie_ok 'もう一つ足す' sh "$s/note.sh" 'ふたつめの気づき'
got=$(cat "$tmp"/*/notes.md)
aerie_has '気づきが残る' 'ひとつめの気づき' "$got"
aerie_has '足されている' 'ふたつめの気づき' "$got"
aerie_fails '中身なしの気づき' sh "$s/note.sh" ''

aerie_ok '引きつぎを書く' sh -c "printf -- '- 次はフックを足す\n' | sh '$s/handoff.sh'"
aerie_fails '文章の引きつぎ' sh -c "printf 'これは文章\n' | sh '$s/handoff.sh'"

got=$(sh "$s/show.sh" 2>&1)
aerie_has 'まとめて出る' '計画' "$got"
aerie_has '気づきも出る' '気づき' "$got"
aerie_has '引きつぎも出る' '引きつぎ' "$got"

got=$(sh "$s/clear.sh" 2>&1)
aerie_has '消す前の知らせ' 'clear.sh -f' "$got"
[ -f "$tmp"/*/plan.md ] || aerie_ng '見ただけで消えてしまいました'

aerie_ok '片づける' sh "$s/clear.sh" -f
got=$(sh "$s/show.sh" 2>&1)
aerie_has '空になる' 'まだありません' "$got"

aerie_test_end
