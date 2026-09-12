# aerie の共通部分
# 読みこむ側で aerie_hooks に hooks ディレクトリの場所を入れておくこと

# 設定ファイルの場所を返す
# プロジェクトの .aerie/ にあればそれを、なければ同梱のものを使う
aerie_config() {
  name=${1##*/}
  if [ -f ".aerie/$name" ]; then
    printf '%s\n' ".aerie/$name"
  else
    printf '%s\n' "$aerie_hooks/configs/$1"
  fi
}

# 検査をぜんぶ走らせて、見つかったことを集めて返す
aerie_run_checks() {
  found=''
  for check in "$aerie_hooks"/tasks/checks/*.sh; do
    [ -f "$check" ] || continue
    result=$(sh "$check" "$@" 2>/dev/null) || result=''
    if [ -n "$result" ]; then
      found="$found$result
"
    fi
  done
  printf '%s' "$found"
}

# 今いるブランチの名前。ファイル名に使えない文字は - に直す
aerie_branch() {
  b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || b=''
  if [ -z "$b" ] || [ "$b" = HEAD ]; then
    b=$(git rev-parse --short HEAD 2>/dev/null) || b=''
  fi
  [ -n "$b" ] || return 1
  b=$(printf '%s' "$b" | tr '/ ' '--' | tr -cd 'A-Za-z0-9._-')
  [ -n "$b" ] || b=unknown
  printf '%s\n' "$b"
}

# 今いるブランチの覚え書きの置き場。作りはしない
aerie_memory_dir() {
  branch=$(aerie_branch) || return 1
  printf '%s/%s\n' "${AERIE_MEMORY_DIR:-.aerie/memory}" "$branch"
}

# テストをぜんぶ走らせて、通らなかったものを一件一行で返す
# 同梱のスキルとフック、それに案件ごとのスキルの tests/ を見る
aerie_run_tests() {
  [ -z "$AERIE_TESTING" ] || return 0
  root=$(CDPATH= cd -- "$aerie_hooks/.." && pwd)
  found=''
  for t in "$root"/skills/*/tests/*.sh "$root"/hooks/tests/*.sh \
           .claude/skills/*/tests/*.sh .aerie/skills/*/tests/*.sh; do
    [ -f "$t" ] || continue
    out=$(AERIE_TESTING=1 sh "$t" 2>&1)
    [ $? -eq 0 ] && continue
    name=${t%/tests/*}
    name=${name##*/}
    first=$(printf '%s' "$out" | head -n 1)
    found="$found$name / ${t##*/}  $first
"
  done
  printf '%s' "$found"
}
