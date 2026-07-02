# ~/.bashrc - yusuke-devbox 用カスタム設定

# -------------------------------------------------------
# ウェルカムメッセージ
# -------------------------------------------------------
if [[ $- == *i* ]]; then
  echo ""
  echo "  Welcome to yusuke-devbox"
  echo "  ─────────────────────────────────────────"
  printf "  %-10s %s\n" "Node.js" "$(node --version 2>/dev/null || echo 'not installed')"
  printf "  %-10s %s\n" "Python" "$(python3 --version 2>/dev/null | awk '{print $2}' || echo 'not installed')"
  printf "  %-10s %s\n" "Rust" "$(rustc --version 2>/dev/null | awk '{print $2}' || echo 'not installed')"
  printf "  %-10s %s\n" ".NET" "$(dotnet --version 2>/dev/null || echo 'not installed')"
  echo "  ─────────────────────────────────────────"
  echo ""
fi

# -------------------------------------------------------
# プロンプト
# -------------------------------------------------------
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\e[36m\]devbox\[\e[0m\]:\[\e[33m\]\w\[\e[32m\]\$(parse_git_branch)\[\e[0m\]\$ "

# -------------------------------------------------------
# 履歴
# -------------------------------------------------------
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# -------------------------------------------------------
# エイリアス読み込み
# -------------------------------------------------------
DEVBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
if [ -f "$DEVBOX_ROOT/dotfiles/.aliases" ]; then
  source "$DEVBOX_ROOT/dotfiles/.aliases"
fi

# -------------------------------------------------------
# パス追加
# -------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# -------------------------------------------------------
# Python
# -------------------------------------------------------
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# -------------------------------------------------------
# エディタ
# -------------------------------------------------------
export EDITOR="code --wait"
export VISUAL="code --wait"
