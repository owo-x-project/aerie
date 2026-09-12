# ブランチごとの覚え書きを扱うスクリプトの共通部分
# 読みこむ側で aerie_scripts にこのファイルの場所を入れておくこと

aerie_root=$(CDPATH= cd -- "$aerie_scripts/../../.." && pwd)
aerie_hooks="$aerie_root/hooks"
. "$aerie_hooks/lib/common.sh"

# 中身を入れる前に長さを見る。越えていたら知らせて 1 を返す
# 使い方: aerie_save <置き場> <ファイル名> <中身>
aerie_save() {
  dir=$1
  file=$2
  text=$3
  tmp=$(mktemp -d) || return 1
  printf '%s\n' "$text" > "$tmp/$file"
  over=$(sh "$aerie_hooks/tasks/checks/tokens.sh" "$tmp/$file" 2>/dev/null)
  if [ -n "$over" ]; then
    printf '長すぎます。短くしてから入れ直してください\n%s\n' "$over" >&2
    rm -rf "$tmp"
    return 1
  fi
  mkdir -p "$dir" || { rm -rf "$tmp"; return 1; }
  cp "$tmp/$file" "$dir/$file" || { rm -rf "$tmp"; return 1; }
  rm -rf "$tmp"
  printf '%s\n' "$dir/$file"
}
