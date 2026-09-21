#!/bin/sh
# 圧縮後に方針を戻す

aerie_hooks=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 0
. "$aerie_hooks/lib/common.sh"

aerie_context_rules
exit 0
