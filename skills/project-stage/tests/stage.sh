#!/bin/sh
# project-stage の段階設定と段階ごとの扱いを試す

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/../../.." && pwd)
. "$root/hooks/lib/test.sh"

tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM

cd "$tmp" || exit 1
stage=$(sh "$root/skills/project-stage/scripts/stage.sh" early)
aerie_eq '段階を設定する' early "$stage"
stage=$(sh "$root/skills/project-stage/scripts/stage.sh")
aerie_eq '段階を出す' early "$stage"

got=$(AERIE_TESTING=1 AERIE_STAGE=early sh "$root/hooks/entrypoints/session-start.sh" 2>&1)
aerie_has '常時方針を注入する' '常時の作業方針' "$got"
aerie_has '正本方針を注入する' 'ソース、試験、コメントを実装の正本にする' "$got"
aerie_has '説明で節を分ける' '### 読み手が誤解しない文章にする' "$got"
aerie_has '初期段階の方針を注入する' '速い試行と学びを優先する' "$got"

mkdir -p "$tmp/rules"
printf '%s\n' '---' 'name: reply-style' 'description: 案件固有の返答' '---' '- 案件の返答を使う' > "$tmp/rules/always-reply-style.md"
got=$(AERIE_TESTING=1 AERIE_RULES_DIR="$tmp/rules" AERIE_STAGE=early sh "$root/hooks/entrypoints/session-start.sh" 2>&1)
aerie_has '案件側の説明を使う' '### 案件固有の返答' "$got"
aerie_has '案件側の本文を使う' '- 案件の返答を使う' "$got"

got=$(AERIE_TESTING=1 AERIE_STAGE=operation sh "$root/hooks/entrypoints/session-start.sh" 2>&1)
aerie_has '運用段階の方針を注入する' '外部の利用者、データ、連携先を変えない' "$got"
got=$(AERIE_TESTING=1 AERIE_STAGE=early sh "$root/hooks/entrypoints/post-compact.sh" 2>&1)
aerie_has '圧縮後も方針を戻す' '速い試行と学びを優先する' "$got"

big="$tmp/always-big.md"
awk 'BEGIN{for(i=0;i<300;i++)print "- あいうえおかきくけこ"}' > "$big"
got=$(AERIE_STAGE=early printf '{"tool_input":{"file_path":"%s"}}' "$big" | AERIE_STAGE=early sh "$root/hooks/entrypoints/after-edit.sh" 2>&1)
aerie_eq '初期段階は長さ超過で止めない' 0 $?
aerie_has '初期段階の知らせ' '初期段階なので止めません' "$got"

got=$(AERIE_STAGE=operation printf '{"tool_input":{"command":"git reset --hard HEAD"}}' | AERIE_STAGE=operation sh "$root/hooks/entrypoints/before-bash.sh" 2>&1)
aerie_eq '運用段階は危険操作を止める' 2 $?
aerie_has '危険操作の理由' '危険な操作のため止めました' "$got"

got=$(AERIE_STAGE=stable printf '{"tool_input":{"command":"git reset --hard HEAD"}}' | AERIE_STAGE=stable sh "$root/hooks/entrypoints/before-bash.sh" 2>&1)
aerie_eq '安定化段階は危険操作を知らせる' 0 $?
aerie_has '安定化段階の知らせ' '危険な操作です' "$got"

aerie_test_end
