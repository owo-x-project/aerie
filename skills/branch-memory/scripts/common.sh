# ブランチごとの覚え書きを扱うスクリプトの共通部分
# 読みこむ側で aerie_scripts にこのファイルの場所を入れておくこと

aerie_root=$(CDPATH= cd -- "$aerie_scripts/../../.." && pwd)

# 今いるブランチの名前。ファイル名に使えない文字は - に直す
aerie_branch() {
  b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || b=''
  if [ -z "$b" ] || [ "$b" = HEAD ]; then
    b=$(git rev-parse --short HEAD 2>/dev/null) || b=''
  fi
  if [ -z "$b" ]; then
    printf 'git のブランチが分かりません\n' >&2
    return 1
  fi
  b=$(printf '%s' "$b" | tr '/ ' '--' | tr -cd 'A-Za-z0-9._-')
  [ -n "$b" ] || b=unknown
  printf '%s\n' "$b"
}

# 今いるブランチの置き場。作りはしない
aerie_memory_dir() {
  branch=$(aerie_branch) || return 1
  printf '%s/%s\n' "${AERIE_MEMORY_DIR:-.aerie/memory}" "$branch"
}

# 中身を入れる前に長さを見る。越えていたら知らせて 1 を返す
# 使い方: aerie_save <置き場> <ファイル名> <中身>
aerie_save() {
  dir=$1
  file=$2
  text=$3
  tmp=$(mktemp -d) || return 1
  printf '%s\n' "$text" > "$tmp/$file"
  over=$(sh "$aerie_root/hooks/tasks/checks/tokens.sh" "$tmp/$file" 2>/dev/null)
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
