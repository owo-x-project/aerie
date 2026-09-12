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
