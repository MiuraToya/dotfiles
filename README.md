# dotfiles

個人用 dotfiles repo。chezmoi + Homebrew + macOS defaults で Mac 環境を宣言的に管理。

## Structure

```
.
├── chezmoi/            # ~/ 配下へ反映する dotfiles
├── homebrew/Brewfile   # CLI / GUI アプリ宣言リスト
├── macos/defaults.sh   # OS 設定スクリプト
├── claude-sandbox/     # Claude Code を bypass モードで隔離起動する Docker 一式
└── install.sh          # 1コマンドで全部セットアップ
```

## Setup (Fresh Mac)

`install.sh` は repo 内にあるため、最初だけ Git が必要です。Xcode Command Line Tools を手動で入れて Apple Git を使える状態にします。

```bash
xcode-select --install
git --version
```

```bash
git clone https://github.com/MiuraToya/dotfiles.git ~/Develop/Project/dotfiles
cd ~/Develop/Project/dotfiles
./install.sh
```

`install.sh` が以下を順に実行：

1. Xcode Command Line Tools が入っていることを確認
2. Homebrew のインストール
3. `brew bundle --file=homebrew/Brewfile` でツール一括インストール
4. `~/.gitconfig.local` を対話的に作成（git で使う email を入力）
5. `chezmoi apply --source=./chezmoi` で `~` 配下に通常ファイルとして反映
6. `git config --global core.hooksPath ~/.config/git/hooks` で全 repo に gitleaks pre-commit 有効化
7. `macos/install-cli.sh` でベンダー公式 CLI ツールをインストール
8. `macos/defaults.sh` で Mac OS 設定適用

## Conflicts with Existing Files

`chezmoi` は symlink ではなく通常ファイルとして `~` 配下へ反映します。既存ファイルとの差分を確認してから反映したい場合は、先に以下を実行してください：

```bash
./scripts/check.sh
chezmoi diff --source=./chezmoi
```

差分に問題なければ `./install.sh` を実行します。
`install.sh` も `chezmoi diff` を表示し、確認してから `chezmoi apply` します。

## Daily Usage

普段の設定変更は `chezmoi/` 配下を正として編集します。`~/.zshrc` など `~` 配下のファイルを直接編集した場合は、同じ変更を `chezmoi/` 側にも戻してください。

```bash
# 反映予定の差分を見る
chezmoi diff --source=./chezmoi

# HOME配下へ反映する
chezmoi apply --source=./chezmoi

# install.shほど重くない安全確認
./scripts/check.sh
```

`install.sh` は初回セットアップや Brewfile / macOS defaults までまとめて適用したいときに使います。日々の dotfiles 反映だけなら `chezmoi apply --source=./chezmoi` で十分です。

## Notes

- **zsh 前提**: `install.sh` は zsh 以外のシェルで警告を出します。`chsh -s $(command -v zsh)` で切り替え推奨
- **public repo**: 秘密情報は commit しない。machine-local な email は `~/.gitconfig.local`（`[include]` で `.gitconfig` から参照）に分離済み
- **gitleaks pre-commit**: セットアップ後は全 git repo の commit 前に staged された差分を gitleaks でスキャンします。検知時に意図的に override したい場合は `git commit --no-verify`

## Claude Code サンドボックス

`--dangerously-skip-permissions`(bypass モード)をホスト直叩きするのは危険なので、
Docker コンテナに隔離して動かす一式が `claude-sandbox/` にあります。任意のリポのルートで
起動すると、そのリポだけが `/workspace` にマウントされる(他のリポやホストの鍵類は見えない)。

```bash
# 任意のリポのルートで:
/path/to/dotfiles/claude-sandbox/run.sh
ENABLE_FIREWALL=1 /path/to/dotfiles/claude-sandbox/run.sh
```

要 Docker Desktop。設計と「ホストと共有する/しない」の判断根拠は `claude-sandbox/README.md` 参照。

## Machine-Local Config

`~/.gitconfig.local` で email をマシンごとに切替。`install.sh` が初回実行時に対話で生成します。

```ini
# ~/.gitconfig.local
[user]
	email = your-email@example.com
```
