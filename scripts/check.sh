#!/usr/bin/env bash
#
# Safe preflight checks for this dotfiles repo.
# This script does not install packages or apply dotfiles.
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

echo "==> Checking shell script syntax"
bash -n install.sh
bash -n macos/defaults.sh
bash -n macos/install-cli.sh
bash -n claude-sandbox/run.sh

echo "==> Checking chezmoi diff"
if command -v chezmoi >/dev/null; then
    chezmoi diff --source="$DOTFILES_DIR/chezmoi" || true
else
    echo "chezmoi is not installed. Skipping dotfile diff."
fi

echo "==> Checking Brewfile without installing or upgrading"
if ! HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --verbose --file=homebrew/Brewfile --no-upgrade; then
    echo "Brewfile has unmet dependencies. This is expected before install."
fi

echo "✓ preflight checks completed"
