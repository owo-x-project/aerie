#!/bin/sh
# task-loop の段階表示と完了検査を試す

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH= cd -- "$here/../../.." && pwd)
. "$root/hooks/lib/test.sh"

cd "$root" || exit 1
aerie_ok '完了検査' sh "$root/skills/task-loop/scripts/close.sh"

aerie_test_end
