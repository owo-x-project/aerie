#!/bin/sh
# 同じ範囲のきまりを知らせる

aerie_scripts=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
aerie_root=$(CDPATH= cd -- "$aerie_scripts/../../.." && pwd) || exit 1
sh "$aerie_root/hooks/tasks/checks/rules.sh"
