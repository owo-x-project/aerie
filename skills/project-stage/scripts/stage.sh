#!/bin/sh
# 現在のプロジェクト段階を出す、または設定する

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
aerie_root=$(CDPATH= cd -- "$aerie_scripts/../../.." && pwd) || exit 1
aerie_hooks="$aerie_root/hooks"
. "$aerie_hooks/lib/common.sh"

if [ "$#" -eq 0 ]; then
  printf '%s\n' "$(aerie_stage)"
  exit 0
fi

case $1 in
  early|stable|operation) ;;
  *)
    printf '%s\n' '段階は early、stable、operation のどれかです' >&2
    exit 1
    ;;
esac

mkdir -p .aerie || exit 1
tmp=$(mktemp .aerie/stage.conf.XXXXXX) || exit 1
trap 'rm -f "$tmp"' EXIT INT TERM
printf '# プロジェクトの段階\nstage %s\n' "$1" > "$tmp" || exit 1
mv "$tmp" .aerie/stage.conf || exit 1
trap - EXIT INT TERM
printf '%s\n' "$1"
