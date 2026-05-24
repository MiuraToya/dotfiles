# dotfiles

個人用 dotfiles repo。GNU Stow + Homebrew + macOS defaults で Mac 環境を宣言的に管理。

## Structure

```
.
├── shell/              # zsh 設定
├── git/                # git 設定
├── editor/             # エディタ設定
├── homebrew/Brewfile   # CLI / GUI アプリ宣言リスト
├── macos/defaults.sh   # OS 設定スクリプト
├── claude-sandbox/     # Claude Code を bypass モードで隔離起動する Docker 一式
└── install.sh          # 1コマンドで全部セットアップ
```

## Setup (Fresh Mac)

```bash
git clone https://github.com/MiuraToya/dotfiles.git ~/Develop/Project/dotfiles
cd ~/Develop/Project/dotfiles
./install.sh
```

`install.sh` が以下を順に実行：

1. Xcode Command Line Tools のインストール
2. Homebrew のインストール
3. `brew bundle --file=homebrew/Brewfile` でツール一括インストール
4. `~/.gitconfig.local` を対話的に作成（git で使う email を入力）
5. `stow shell git editor` で `~` 配下に symlink 展開
6. `git config --global core.hooksPath ~/.config/git/hooks` で全 repo に gitleaks pre-commit 有効化
7. `macos/defaults.sh` で Mac OS 設定適用

## Conflicts with Existing Files

`~/.zshrc` / `~/.zprofile` / `~/.gitconfig` が **通常ファイルとして既に存在する** Mac では、`stow` が衝突エラーで失敗します。事前に削除してから `install.sh` を実行してください：

```bash
rm ~/.zshrc ~/.zprofile ~/.gitconfig
```

（中身は repo の `shell/` と `git/` に保持されているので失われません）

## Notes

- **zsh 前提**: `install.sh` は zsh 以外のシェルで警告を出します。`chsh -s $(command -v zsh)` で切り替え推奨
- **public repo**: 秘密情報は commit しない。machine-local な email は `~/.gitconfig.local`（`[include]` で `.gitconfig` から参照）に分離済み
- **gitleaks pre-commit**: セットアップ後は全 git repo の commit 前に gitleaks スキャンが自動実行されます。検知時に意図的に override したい場合は `git commit --no-verify`

## Claude Code サンドボックス

`--dangerously-skip-permissions`(bypass モード)をホスト直叩きするのは危険なので、
Docker コンテナに隔離して動かす一式が `claude-sandbox/` にあります。任意のリポのルートで
起動すると、そのリポだけが `/workspace` にマウントされる(他のリポやホストの鍵類は見えない)。

```bash
# `claude-box` エイリアスは shell/.zshrc 済み。任意のリポのルートで:
claude-box                  # そのリポをマウントして bypass モード起動
ENABLE_FIREWALL=1 claude-box  # 通信も Anthropic / GitHub / npm に制限
```

要 Docker Desktop。設計と「ホストと共有する/しない」の判断根拠は `claude-sandbox/README.md` 参照。

## Machine-Local Config

`~/.gitconfig.local` で email をマシンごとに切替。`install.sh` が初回実行時に対話で生成します。

```ini
# ~/.gitconfig.local
[user]
	email = your-email@example.com
```
