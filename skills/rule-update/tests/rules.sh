#!/bin/sh
# rule-update のスクリプトを試す

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/../../.." && pwd)
. "$root/hooks/lib/test.sh"

s="$here/../scripts"
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM
export AERIE_RULES_DIR="$tmp"

# 設定ファイルを読む作業ディレクトリを切り、呼び出し元プロジェクトの上限設定に左右されないようにする。
project="$tmp/project"
mkdir -p "$project"
cd "$project" || exit 1

aerie_ok '作る' sh -c "printf -- '- みじかく書く\n' | sh '$s/write.sh' always reply-test 'テスト用の返答'"
[ -f "$tmp/always-reply-test.md" ] || aerie_ng '作ったファイルがありません'

got=$(sh "$s/show.sh" always reply-test 2>&1)
aerie_has '中身' 'みじかく書く' "$got"
aerie_has '頭' 'name: reply-test' "$got"
aerie_has '説明' 'description: テスト用の返答' "$got"

aerie_ok '合わせる形つき' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' path md-test '*.md' 'テスト用の対象'"
got=$(sh "$s/show.sh" path md-test 2>&1)
aerie_has '合わせる形' 'match: *.md' "$got"

aerie_fails '知らない種類' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' other x '試験用の説明'"
aerie_fails '大文字の名前' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' always Bad '試験用の説明'"
aerie_fails '説明なし' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' always no-description"
aerie_fails '文章の本文' sh -c "printf 'これは文章\n' | sh '$s/write.sh' always bad-test '試験用の説明'"
aerie_fails '中身なし' sh -c ": | sh '$s/write.sh' always empty-test '空の試験'"
aerie_fails 'path に形なし' sh -c "printf -- '- ためし\n' | sh '$s/write.sh' path no-match '' '試験用の説明'"
aerie_fails '長すぎ' sh -c "awk 'BEGIN{for(i=0;i<300;i++)print \"- あいうえおかきくけこ\"}' | sh '$s/write.sh' always long-test '長さの試験'"
[ -f "$tmp/always-long-test.md" ] && aerie_ng '長すぎるものが入ってしまいました'

got=$(sh "$s/list.sh" 2>&1)
aerie_has '一覧' 'always-reply-test.md' "$got"
aerie_has '同梱の文章きまり' 'always-clear-writing.md' "$got"
got=$(sh "$s/show.sh" always clear-writing 2>&1)
aerie_has '文章きまりの具体性' '固有名、数値、実例' "$got"

aerie_ok 'やめる' sh "$s/drop.sh" always reply-test
[ -f "$tmp/always-reply-test.md" ] && aerie_ng 'やめたのに残っています'
aerie_fails 'ないものをやめる' sh "$s/drop.sh" always nothing-here
aerie_fails 'ないものを見る' sh "$s/show.sh" always nothing-here

aerie_test_end
