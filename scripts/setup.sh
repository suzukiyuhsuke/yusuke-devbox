#!/usr/bin/env bash
# setup.sh - DevBox 初回セットアップスクリプト
set -euo pipefail

DEVBOX_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "========================================="
echo "  yusuke-devbox: 初回セットアップ"
echo "========================================="

# -------------------------------------------------------
# 1. ディレクトリ構成の作成
# -------------------------------------------------------
echo "[1/5] ディレクトリ構成を作成中..."
mkdir -p "$DEVBOX_ROOT"/{projects,docs,workspaces,dotfiles}

# -------------------------------------------------------
# 2. ワークスペースファイルの生成
# -------------------------------------------------------
WORKSPACE_FILE="$DEVBOX_ROOT/workspaces/devbox.code-workspace"
if [ ! -f "$WORKSPACE_FILE" ]; then
  echo "[2/5] ワークスペースファイルを生成中..."
  cat > "$WORKSPACE_FILE" <<'EOF'
{
  "folders": [
    {
      "name": "🏠 DevBox Root",
      "path": ".."
    }
  ],
  "settings": {
    "files.exclude": {
      "**/node_modules": true,
      "**/__pycache__": true,
      "**/.terraform": true
    }
  }
}
EOF
else
  echo "[2/5] ワークスペースファイルは既に存在します。スキップ。"
fi

# -------------------------------------------------------
# 3. dotfiles のシンボリックリンク作成
# -------------------------------------------------------
echo "[3/5] dotfiles を確認中..."
for dotfile in "$DEVBOX_ROOT"/dotfiles/.*; do
  filename="$(basename "$dotfile")"
  # .  ..  .gitkeep などはスキップ
  [[ "$filename" == "." || "$filename" == ".." || "$filename" == ".gitkeep" ]] && continue
  target="$HOME/$filename"
  if [ ! -e "$target" ]; then
    ln -s "$dotfile" "$target"
    echo "  リンク作成: $target -> $dotfile"
  else
    echo "  スキップ（既存）: $target"
  fi
done

# -------------------------------------------------------
# 4. Python 仮想環境の作成（projects 用共通 venv）
# -------------------------------------------------------
VENV_DIR="$DEVBOX_ROOT/.venv"
if [ ! -d "$VENV_DIR" ]; then
  echo "[4/5] Python 仮想環境を作成中..."
  python3 -m venv "$VENV_DIR"
  source "$VENV_DIR/bin/activate"
  pip install --upgrade pip --quiet
  echo "  仮想環境: $VENV_DIR"
else
  echo "[4/5] 仮想環境は既に存在します。スキップ。"
fi

# -------------------------------------------------------
# 5. Git エイリアスの設定
# -------------------------------------------------------
echo "[5/5] Git エイリアスを設定中..."
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.lg "log --oneline --graph --decorate -20"

echo ""
echo "========================================="
echo "  セットアップ完了！"
echo "  ワークスペースを開く:"
echo "    code workspaces/devbox.code-workspace"
echo "========================================="
