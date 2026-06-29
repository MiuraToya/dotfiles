#!/usr/bin/env bash
# macOS defaults — captured from personal Mac on 2026-05-20
set -euo pipefail

# === Mouse / Trackpad ===
defaults write -g com.apple.mouse.scaling      -float 1.5
defaults write -g com.apple.trackpad.scaling   -float 1.5
defaults write -g com.apple.scrollwheel.scaling -float 0.4412
defaults write -g com.apple.swipescrolldirection -bool false

# === Dock ===
defaults write com.apple.dock autohide      -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize      -int  23
defaults write com.apple.dock largesize     -int  79

# === Clock (秒表示・24h・曜日あり・日付あり) ===
defaults write com.apple.menuextra.clock ShowSeconds   -bool true
defaults write com.apple.menuextra.clock Show24Hour    -bool true
defaults write com.apple.menuextra.clock ShowDate      -int  1
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowAMPM      -bool false

# === Apply ===
killall Dock           2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
