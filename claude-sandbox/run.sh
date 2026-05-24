#!/usr/bin/env bash
# どのリポからでも使える Claude Code サンドボックス起動ラッパ。
#
# 使い方(任意のリポのルートで):
#   /path/to/claude-sandbox/run.sh         # そのリポをマウントしてバイパスモード起動
#   /path/to/claude-sandbox/run.sh bash    # 中を確認したいときはシェルで入る
#   ENABLE_FIREWALL=1 /path/to/claude-sandbox/run.sh   # egress を許可リストに制限
#
# 例) よく使うならエイリアスにすると "さくっと" 使える:
#   alias claude-box='/path/to/claude-sandbox/run.sh'
#   → 任意のリポで `claude-box` と打つだけ
set -euo pipefail

# マウント対象 = このスクリプトを実行したときのカレントディレクトリ(= 使いたいリポ)。
PROJECT_DIR="${PWD}"
# サンドボックス定義(Dockerfile / compose)の場所 = このスクリプトのある所。
SANDBOX_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$PROJECT_DIR" = "$SANDBOX_DIR" ]; then
  echo "⚠️  サンドボックス自身のフォルダで実行しています。" >&2
  echo "    マウントしたいリポのルートに cd してから実行してください。" >&2
fi

echo "▶ mount: $PROJECT_DIR  →  /workspace"

cd "$SANDBOX_DIR"
export SANDBOX_WORKDIR="$PROJECT_DIR"

# イメージが無ければビルド(初回のみ数分)。更新したいときは手動で:
#   docker compose build --no-cache
if ! docker image inspect claude-sandbox:latest >/dev/null 2>&1; then
  docker compose build
fi

# --rm: 終了時にコンテナを破棄(状態は named volume にのみ残る)
exec docker compose run --rm claude "$@"
