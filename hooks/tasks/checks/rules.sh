#!/bin/sh
# 同じ対象に複数のきまりが効いていないか知らせる

aerie_hooks=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd) || exit 0
aerie_root=$(CDPATH= cd -- "$aerie_hooks/.." && pwd) || exit 0
builtin="$aerie_root/skills/rule-update/assets"
project=${AERIE_RULES_DIR:-.aerie/rules}

emit() {
  file=$1
  base=${file##*/}
  kind=${base%%-*}
  case "$kind" in
    path|tool) ;;
    *) return 0 ;;
  esac
  match=$(awk '
    /^---$/ { n++; next }
    n == 1 && /^match:/ { sub(/^match:[ \t]*/, ""); print; exit }
  ' "$file")
  [ -n "$match" ] || return 0
  printf '%s\t%s\t%s\n' "$base" "$kind" "$match"
}

{
  for file in "$builtin"/*.md; do
    [ -f "$file" ] || continue
    emit "$file"
  done
  if [ "$project" != "$builtin" ]; then
    for file in "$project"/*.md; do
      [ -f "$file" ] || continue
      emit "$file"
    done
  fi
} | awk -F '\t' '
  {
    file[$1] = $1
    kind[$1] = $2
    pat[$1] = $3
  }
  END {
    for (name in file) {
      key = kind[name] "\034" pat[name]
      if (seen[key] != "")
        printf "同じ範囲のきまりです。%s %s: %s と %s\n", kind[name], pat[name], seen[key], name
      else
        seen[key] = name
    }
  }
'

exit 0
