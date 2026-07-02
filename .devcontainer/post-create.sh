#!/usr/bin/env bash
set -euo pipefail

echo "=== yusuke-devbox: post-create setup ==="

# -------------------------------------------------------
# Node.js: 最新 LTS をインストールしてデフォルトに設定
# -------------------------------------------------------
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck source=/dev/null
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # Some third-party init scripts reference unset vars; relax nounset only while sourcing.
  set +u
  . "$NVM_DIR/nvm.sh"
  set -u
fi
if command -v nvm >/dev/null 2>&1; then
  nvm install --lts
  nvm alias default lts/*
fi

# -------------------------------------------------------
# Java: 最新 LTS を SDKMAN 経由でインストールしてデフォルトに設定
# -------------------------------------------------------
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
set +u
# shellcheck source=/dev/null
if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  # SDKMAN init can read optional shell vars (for example ZSH_VERSION).
  . "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
if command -v sdk >/dev/null 2>&1; then
  # SDKMAN が利用可能な場合のみ最新 Temurin 候補を更新する。
  java_candidate="$(sdk list java | awk '{for (i = 1; i <= NF; i++) if ($i ~ /-tem$/) {print $i; exit}}')"
  if [ -n "$java_candidate" ]; then
    # Avoid interactive prompt in post-create by auto-confirming default selection.
    printf 'Y\n' | sdk install java "$java_candidate" || true
  fi
fi
set -u

# -------------------------------------------------------
# Python: AI / ML 関連パッケージ
# -------------------------------------------------------
python3 -m pip install --upgrade pip
python3 -m pip install \
  azure-ai-projects \
  azure-ai-inference \
  azure-identity \
  python-dotenv \
  httpx \
  ruff

# -------------------------------------------------------
# ディレクトリ構成の初期化
# -------------------------------------------------------
mkdir -p projects scripts dotfiles docs workspaces

# -------------------------------------------------------
# Dotfiles のセットアップ
# -------------------------------------------------------
if [ -f "$PWD/dotfiles/.bashrc" ]; then
  ln -sf "$PWD/dotfiles/.bashrc" "$HOME/.bashrc"
fi
if [ -f "$PWD/dotfiles/.aliases" ]; then
  ln -sf "$PWD/dotfiles/.aliases" "$HOME/.aliases"
fi

# -------------------------------------------------------
# Git の基本設定（Codespaces が自動設定しない項目）
# -------------------------------------------------------
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global fetch.prune true

echo "=== post-create setup complete ==="
