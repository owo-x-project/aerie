#!/bin/sh
# ファイルを書いた直後に、そのファイルだけ検査する

aerie_hooks=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 0
. "$aerie_hooks/lib/common.sh"

file=$(awk '
  match($0, /"file_path"[ \t]*:[ \t]*"([^"\\]|\\.)*"/) {
    s = substr($0, RSTART, RLENGTH)
    sub(/^"file_path"[ \t]*:[ \t]*"/, "", s)
    sub(/"$/, "", s)
    gsub(/\\"/, "\"", s)
    gsub(/\\\\/, "\\", s)
    print s
    exit
  }
')
[ -n "$file" ] || exit 0

case "$file" in
  "$PWD"/*) file=${file#"$PWD"/} ;;
esac
[ -f "$file" ] || exit 0

found=$(aerie_run_checks "$file")
[ -n "$found" ] || exit 0

case $(aerie_stage_action edit) in
  warn)
    printf '%s\n上限を超えました。初期段階なので止めません。必要なら分けるか短くしてください。\n' "$found" >&2
    exit 0
    ;;
  *)
    printf '%s\n上限を超えました。分けるか短くしてから進めてください。\n' "$found" >&2
    exit 2
    ;;
esac
