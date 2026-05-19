#!/usr/bin/env bash
#
# Bootstrap script for setting up a Mac from this dotfiles repo.
#
# NOTE: If running on a Mac that already has ~/.zshrc, ~/.zprofile, or ~/.gitconfig
#       as regular files, `stow` will fail at step 5 with a conflict error.
#       Manually remove the conflicting files first:
#           rm ~/.zshrc ~/.zprofile ~/.gitconfig
#       (Their content is already preserved in this repo under shell/ and git/.)
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# 0. Shell check (このdotfilesはzsh前提)
if [[ "$SHELL" != *zsh ]]; then
    echo "⚠️  現在のシェル: $SHELL"
    echo "   このdotfilesはzsh前提です。"
    echo "   zshへ切り替えるには: chsh -s \$(command -v zsh)"
    echo ""
    read -rp "このまま続行しますか？ (y/N) " answer
    [[ "$answer" =~ ^[Yy] ]] || { echo "中止しました"; exit 1; }
fi

# 1. Xcode Command Line Tools
xcode-select -p &>/dev/null || xcode-select --install

# 2. Homebrew
command -v brew &>/dev/null || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Brewfile
brew bundle --file=homebrew/Brewfile

# 4. ~/.gitconfig.local (machine-specific email, prompted on first run)
if [ ! -f "$HOME/.gitconfig.local" ]; then
    read -rp "Gitで使うemail: " GIT_EMAIL
    cat > "$HOME/.gitconfig.local" <<EOF
[user]
	email = ${GIT_EMAIL}
EOF
    echo "~/.gitconfig.local を作成しました"
fi

# 5. Stow packages
stow shell git editor

# 6. Set global git hooks path so pre-commit gitleaks runs in every repo
git config --global core.hooksPath ~/.config/git/hooks

# 7. macOS defaults
./macos/defaults.sh

echo "✅ セットアップ完了"
