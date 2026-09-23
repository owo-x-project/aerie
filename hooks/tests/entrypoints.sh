#!/bin/sh
# フックの入口を試す

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/.." && pwd)
. "$root/lib/test.sh"

# このテストは、超過時に入口が止める安定化段階の動きを検査する。
# 呼び出し元のプロジェクト段階に結果を左右されないよう固定する。
export AERIE_STAGE=stable

tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT INT TERM
project="$tmp/project"
mkdir -p "$project/.aerie"
cat > "$project/.aerie/tokens.conf" <<'CONF'
# 同梱の上限に加えて、プロジェクト固有の除外を指定する
addons/godot_mcp/** -
CONF

# 書いた直後の検査
# この入口では既定の行数上限を超えるテキストで停止を確認する。
big="$tmp/oversized.txt"
awk 'BEGIN{for(i=0;i<701;i++)print "long enough line"}' > "$big"
printf '{"tool_input":{"file_path":"%s"}}' "$big" | (cd "$project" && sh "$root/entrypoints/after-edit.sh") >/dev/null 2>&1
aerie_eq '大きいものを書いたら止める' 2 $?

printf -- '- みじかい\n' > "$tmp/always-small.md"
printf '{"tool_input":{"file_path":"%s"}}' "$tmp/always-small.md" | (cd "$project" && sh "$root/entrypoints/after-edit.sh") >/dev/null 2>&1
aerie_eq 'みじかいものは通す' 0 $?

printf '{"tool_input":{}}' | (cd "$project" && sh "$root/entrypoints/after-edit.sh") >/dev/null 2>&1
aerie_eq 'ファイルの名前がなくても静か' 0 $?

# マージの前の見張り
mem="$tmp/memory"
export AERIE_MEMORY_DIR="$mem"

merge='{"tool_input":{"command":"git merge main"}}'
printf '%s' "$merge" | sh "$root/entrypoints/before-bash.sh" >/dev/null 2>&1
aerie_eq '覚え書きがなければ通す' 0 $?

branch=$(cd "$root/.." && git rev-parse --abbrev-ref HEAD 2>/dev/null | tr '/ ' '--')
mkdir -p "$mem/$branch"
printf -- '- 気づいたこと\n' > "$mem/$branch/notes.md"

got=$(printf '%s' "$merge" | sh "$root/entrypoints/before-bash.sh" 2>&1)
aerie_eq '覚え書きが残っていたら止める' 2 $?
aerie_has '止めたわけを伝える' 'clear.sh -f' "$got"

printf '{"tool_input":{"command":"gh pr create --fill"}}' | sh "$root/entrypoints/before-bash.sh" >/dev/null 2>&1
aerie_eq 'プルリクの前も止める' 2 $?

printf '{"tool_input":{"command":"git merge --abort"}}' | sh "$root/entrypoints/before-bash.sh" >/dev/null 2>&1
aerie_eq 'やめる操作は通す' 0 $?

printf '{"tool_input":{"command":"ls"}}' | sh "$root/entrypoints/before-bash.sh" >/dev/null 2>&1
aerie_eq '関わりのない命令は通す' 0 $?

# セッションの始め
got=$(cd "$root/.." && AERIE_MEMORY_DIR="$mem" sh "$root/entrypoints/session-start.sh" 2>&1)
aerie_eq 'セッションの始めは止めない' 0 $?
aerie_has '覚え書きを出す' '気づいたこと' "$got"
aerie_has '片づけを促す' 'clear.sh -f' "$got"

aerie_test_end
