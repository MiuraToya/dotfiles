# Claude Code (native installer 配置先, macOSでは自動追加されないため明示)
export PATH="$HOME/.local/bin:$PATH"

# Claude Code サンドボックス: bypass モードをコンテナに隔離して任意リポで起動
# (カレントのリポが /workspace にマウントされる。詳細は claude-sandbox/README.md)
alias claude-box='$HOME/Develop/Project/dotfiles/claude-sandbox/run.sh'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# direnv
eval "$(direnv hook zsh)"

# oh my posh
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes.json)"
export TERM=xterm-256color

# zsh-autosuggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
