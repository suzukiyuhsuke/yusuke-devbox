#!/usr/bin/env bash
set -euo pipefail

echo "=== yusuke-devbox: post-create setup ==="

# -------------------------------------------------------
# Python: AI / ML 関連パッケージ
# -------------------------------------------------------
pip install --upgrade pip
pip install \
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
# Git の基本設定（Codespaces が自動設定しない項目）
# -------------------------------------------------------
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global fetch.prune true

echo "=== post-create setup complete ==="
