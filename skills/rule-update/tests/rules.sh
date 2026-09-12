#!/bin/sh
# rule-update のスクリプトを試す

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/../../.." && pwd)
. "$root/hooks/lib/test.sh"

s="$here/../scripts"
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM
export AERIE_RULES_DIR="$tmp"

aerie_ok '作る' sh -c "printf -- '- みじかく書く\n' | sh '$s/write.sh' always reply-test"
[ -f "$tmp/always-reply-test.md" ] || aerie_ng '作ったファイルがありません'

got=$(sh "$s/show.sh" always reply-test 2>&1)
aerie_has '中身' 'みじかく書く' "$got"
aerie_has '頭' 'name: reply-test' "$got"

aerie_ok '合わせる形つき' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' path md-test '*.md'"
got=$(sh "$s/show.sh" path md-test 2>&1)
aerie_has '合わせる形' 'match: *.md' "$got"

aerie_fails '知らない種類' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' other x"
aerie_fails '大文字の名前' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' always Bad"
aerie_fails '文章の本文' sh -c "printf 'これは文章\n' | sh '$s/write.sh' always bad-test"
aerie_fails '中身なし' sh -c ": | sh '$s/write.sh' always empty-test"
aerie_fails 'always に形' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' always with-match '*.md'"
aerie_fails 'path に形なし' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' path no-match"
aerie_fails '長すぎ' sh -c "awk 'BEGIN{for(i=0;i<300;i++)print \"- あいうえおかきくけこ\"}' | sh '$s/write.sh' always long-test"
[ -f "$tmp/always-long-test.md" ] && aerie_ng '長すぎるものが入ってしまいました'

got=$(sh "$s/list.sh" 2>&1)
aerie_has '一覧' 'always-reply-test.md' "$got"

aerie_ok 'やめる' sh "$s/drop.sh" always reply-test
[ -f "$tmp/always-reply-test.md" ] && aerie_ng 'やめたのに残っています'
aerie_fails 'ないものをやめる' sh "$s/drop.sh" always nothing-here
aerie_fails 'ないものを見る' sh "$s/show.sh" always nothing-here

aerie_test_end
