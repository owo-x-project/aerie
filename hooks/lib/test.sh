# テストを書くための共通部分
# 落ちたことがあれば aerie_test_end が 1 で終わる

aerie_failed=0

# 落ちたことを書きとめる
aerie_ng() {
  printf '%s\n' "$*"
  aerie_failed=1
}

# 通るはずのもの。使い方: aerie_ok '名前' コマンド...
aerie_ok() {
  desc=$1
  shift
  if ! "$@" >/dev/null 2>&1; then
    aerie_ng "$desc が通りませんでした"
  fi
}

# 落ちるはずのもの。使い方: aerie_fails '名前' コマンド...
aerie_fails() {
  desc=$1
  shift
  if "$@" >/dev/null 2>&1; then
    aerie_ng "$desc は止まるはずが通ってしまいました"
  fi
}

# 中身くらべ。使い方: aerie_eq '名前' <ほしいもの> <あったもの>
aerie_eq() {
  if [ "$2" != "$3" ]; then
    aerie_ng "$1 が合いません。ほしい [$2] あった [$3]"
  fi
}

# 中に入っているか。使い方: aerie_has '名前' <さがす字> <文>
aerie_has() {
  case $3 in
    *"$2"*) ;;
    *) aerie_ng "$1 に [$2] がありません" ;;
  esac
}

aerie_test_end() {
  exit $aerie_failed
}
