#!/usr/bin/env bash
# macOS defaults — captured from personal Mac on 2026-05-20
set -euo pipefail

# === Mouse / Trackpad ===
# マウスカーソルの移動速度。値が大きいほど速い。
defaults write -g com.apple.mouse.scaling      -float 1.5
# トラックパッドカーソルの移動速度。値が大きいほど速い。
defaults write -g com.apple.trackpad.scaling   -float 1.5
# マウスホイール・トラックパッドのスクロール速度。値が大きいほど速い。
defaults write -g com.apple.scrollwheel.scaling -float 0.4412
# スクロール方向。false は「ナチュラルなスクロール」をオフにする。
defaults write -g com.apple.swipescrolldirection -bool false

# === Dock ===
# Dock を自動的に隠す。
defaults write com.apple.dock autohide      -bool true
# Dock アイコンにマウスを重ねたときの拡大表示を有効にする。
defaults write com.apple.dock magnification -bool true
# Dock アイコンの通常サイズ。
defaults write com.apple.dock tilesize      -int  23
# Dock アイコン拡大時の最大サイズ。
defaults write com.apple.dock largesize     -int  79

# === Clock (秒表示・24h・曜日あり・日付あり) ===
# メニューバー時計に秒を表示する。
defaults write com.apple.menuextra.clock ShowSeconds   -bool true
# メニューバー時計を 24 時間表記にする。
defaults write com.apple.menuextra.clock Show24Hour    -bool true
# メニューバー時計に日付を表示する。1 は表示。
defaults write com.apple.menuextra.clock ShowDate      -int  1
# メニューバー時計に曜日を表示する。
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
# メニューバー時計の AM/PM 表示を無効にする。
defaults write com.apple.menuextra.clock ShowAMPM      -bool false

# === Apply ===
# Dock 設定を反映するため Dock を再起動する。
killall Dock           2>/dev/null || true
# メニューバー時計など SystemUIServer 管理の設定を反映するため再起動する。
killall SystemUIServer 2>/dev/null || true
