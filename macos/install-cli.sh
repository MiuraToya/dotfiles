#!/usr/bin/env bash
#
# Install vendor-official CLI tools that are not available via Brewfile.
# 各ツールはコマンドが既にあればスキップ(冪等)。
#
set -euo pipefail

# Claude Code (native installer, ~/.local/bin/claude に配置)
# macOSでは PATH 自動追加されないので shell/.zshrc 側で対応済み
command -v claude &>/dev/null || curl -fsSL https://claude.ai/install.sh | bash
