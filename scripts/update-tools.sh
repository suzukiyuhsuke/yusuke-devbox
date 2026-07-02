#!/usr/bin/env bash
# update-tools.sh - 開発ツールの一括アップデート
set -euo pipefail

echo "========================================="
echo "  yusuke-devbox: ツールアップデート"
echo "========================================="

# -------------------------------------------------------
# Python パッケージ
# -------------------------------------------------------
echo "[1/4] Python パッケージを更新中..."
pip install --upgrade \
  pip \
  azure-ai-projects \
  azure-ai-inference \
  azure-identity \
  python-dotenv \
  httpx \
  ruff \
  --quiet
echo "  完了"

# -------------------------------------------------------
# Azure CLI 拡張機能
# -------------------------------------------------------
echo "[2/4] Azure CLI 拡張機能を更新中..."
if command -v az &> /dev/null; then
  az extension list --query "[].name" -o tsv | while read -r ext; do
    az extension update --name "$ext" 2>/dev/null || true
  done
  echo "  完了"
else
  echo "  スキップ（az CLI が見つかりません）"
fi

# -------------------------------------------------------
# GitHub CLI 拡張機能
# -------------------------------------------------------
echo "[3/4] GitHub CLI 拡張機能を更新中..."
if command -v gh &> /dev/null; then
  gh extension upgrade --all 2>/dev/null || true
  echo "  完了"
else
  echo "  スキップ（gh CLI が見つかりません）"
fi

# -------------------------------------------------------
# npm グローバルパッケージ
# -------------------------------------------------------
echo "[4/4] npm グローバルパッケージを更新中..."
if command -v npm &> /dev/null; then
  npm update -g --silent 2>/dev/null || true
  echo "  完了"
else
  echo "  スキップ（npm が見つかりません）"
fi

echo ""
echo "========================================="
echo "  ツールアップデート完了！"
echo "========================================="
