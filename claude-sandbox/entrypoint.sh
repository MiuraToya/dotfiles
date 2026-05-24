#!/usr/bin/env bash
set -euo pipefail

# ENABLE_FIREWALL=1 のときだけ、何かを始める前に egress(外向き通信)を
# 許可リスト方式に絞り込む。万一の情報持ち出しに対する第二の防御線。
if [ "${ENABLE_FIREWALL:-0}" = "1" ]; then
  echo "[entrypoint] applying network allowlist..." >&2
  sudo /usr/local/bin/init-firewall.sh
fi

exec "$@"
