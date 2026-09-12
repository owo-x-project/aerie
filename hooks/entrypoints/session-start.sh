#!/bin/sh
# セッションの始めに検査をぜんぶ走らせて、残っていることを伝える

aerie_hooks=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 0
. "$aerie_hooks/lib/common.sh"

found=$(aerie_run_checks)
[ -n "$found" ] || exit 0

printf '次のファイルが上限を超えています。作業を始める前に、まずこれを直すか、上限の見直しを利用者に相談してください。\n\n%s\n上限は .aerie/tokens.conf で変えられます。\n' "$found"
