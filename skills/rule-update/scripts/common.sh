# ルールを扱うスクリプトの共通部分
# 読みこむ側で aerie_scripts にこのファイルの場所を入れておくこと

aerie_root=$(CDPATH= cd -- "$aerie_scripts/../../.." && pwd)

# 同梱のルール置き場
aerie_rules_builtin=$(CDPATH= cd -- "$aerie_scripts/.." && pwd)/assets

# 書きこむ先。AERIE_RULES_DIR があればそこを使う
aerie_rules_dir=${AERIE_RULES_DIR:-.aerie/rules}

# 書きこむ先が同梱と同じ場所かどうか
aerie_same_dir() {
  d=$(CDPATH= cd -- "$aerie_rules_dir" 2>/dev/null && pwd) || return 1
  [ "$d" = "$aerie_rules_builtin" ]
}

# 種類と名前からファイル名を作る。おかしければ何も返さずに 1 を返す
aerie_rule_file() {
  case $1 in
    always|path|tool) ;;
    *) printf '種類は always か path か tool です: %s\n' "$1" >&2; return 1 ;;
  esac
  case $2 in
    '' | *[!a-z0-9-]* | -* | *-)
      printf '名前は小文字の英数字とハイフンだけです: %s\n' "$2" >&2; return 1 ;;
  esac
  printf '%s-%s.md\n' "$1" "$2"
}

# ファイルの頭から match を取り出す
aerie_rule_match() {
  awk '
    /^---$/ { d++; if (d == 2) exit; next }
    d == 1 && /^match:/ { sub(/^match:[ \t]*/, ""); print; exit }
  ' "$1"
}
