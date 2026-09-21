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

# 今のプロジェクト段階。設定がなければ従来どおり stable とする
aerie_stage() {
  if [ -n "${AERIE_STAGE:-}" ]; then
    aerie_stage_name=$AERIE_STAGE
  else
    aerie_stage_file=$(aerie_config stage.conf 2>/dev/null) || aerie_stage_file=''
    aerie_stage_name=$(awk '
      /^[ \t]*#/ { next }
      $1 == "stage" { print $2; exit }
    ' "$aerie_stage_file" 2>/dev/null)
  fi
  case "$aerie_stage_name" in
    early|stable|operation) printf '%s\n' "$aerie_stage_name" ;;
    *) printf '%s\n' stable ;;
  esac
}

# 段階に応じた扱い。early は知らせるだけ、stable は従来どおり、
# operation は危険な操作も止める。
aerie_stage_action() {
  case $1:$(aerie_stage) in
    edit:early|memory:early) printf '%s\n' warn ;;
    edit:stable|edit:operation|memory:stable|memory:operation) printf '%s\n' block ;;
    risk:early) printf '%s\n' quiet ;;
    risk:stable) printf '%s\n' warn ;;
    risk:operation) printf '%s\n' block ;;
    *) printf '%s\n' warn ;;
  esac
}

# 現在の段階だけの作業方針を出す
aerie_stage_instructions() {
  aerie_stage_file="$aerie_hooks/../skills/project-stage/assets/$(aerie_stage).md"
  [ -f "$aerie_stage_file" ] || return 0
  cat "$aerie_stage_file"
}

# 正本の頭書きを外して、常時使うきまりだけを出す
aerie_rule_body() {
  awk '
    /^---$/ {
      fence++
      next
    }
    fence >= 2 { print }
  ' "$1"
}

# ルールの説明を頭書きから取り出す
aerie_rule_description() {
  awk '
    /^---$/ { fence++; next }
    fence == 1 && /^description:/ {
      sub(/^description:[ 	]*/, "")
      print
      exit
    }
  ' "$1"
}

# 同梱の常時きまりを案件側の同名ファイルで上書きして出す
aerie_always_rules() {
  aerie_builtin="$aerie_hooks/../skills/rule-update/assets"
  aerie_project=${AERIE_RULES_DIR:-.aerie/rules}
  aerie_seen=''

  for aerie_file in "$aerie_builtin"/always-*.md; do
    [ -f "$aerie_file" ] || continue
    aerie_base=${aerie_file##*/}
    if [ -f "$aerie_project/$aerie_base" ]; then
      aerie_file="$aerie_project/$aerie_base"
    fi
    aerie_seen="$aerie_seen|$aerie_base|"
    aerie_description=$(aerie_rule_description "$aerie_file")
    [ -n "$aerie_description" ] || aerie_description=${aerie_base#always-}
    aerie_description=${aerie_description%.md}
    printf '### %s\n' "$aerie_description"
    aerie_rule_body "$aerie_file"
    printf '\n'
  done

  for aerie_file in "$aerie_project"/always-*.md; do
    [ -f "$aerie_file" ] || continue
    aerie_base=${aerie_file##*/}
    case "$aerie_seen" in
      *"|$aerie_base|"*) continue ;;
    esac
    aerie_description=$(aerie_rule_description "$aerie_file")
    [ -n "$aerie_description" ] || aerie_description=${aerie_base#always-}
    aerie_description=${aerie_description%.md}
    printf '### %s\n' "$aerie_description"
    aerie_rule_body "$aerie_file"
    printf '\n'
  done
}

# セッション開始と圧縮後に同じ方針を注入する
aerie_context_rules() {
  printf 'プロジェクト段階: %s\n\n' "$(aerie_stage)"
  printf '## 常時の作業方針\n'
  aerie_always_rules
  printf '## 段階別の作業方針\n'
  aerie_stage_instructions
  printf '\n'
}

# 危険な操作を短い名前で返す。判定は段階側で行う。
aerie_risk_of() {
  case $1 in
    *"rm -rf"*|*"git reset --hard"*|*"git clean -fd"*|*"git clean -xdf"*)
      printf '%s\n' '削除や作業内容の破棄' ;;
    *"git push --force"*|*"git push -f "*)
      printf '%s\n' '履歴の強制更新' ;;
    *"DROP TABLE"*|*"drop table"*|*"kubectl delete"*)
      printf '%s\n' '共有データの削除' ;;
  esac
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
