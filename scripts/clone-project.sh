#!/usr/bin/env bash
# clone-project.sh - プロジェクトを projects/ にクローンし、ワークスペースに追加
set -euo pipefail

DEVBOX_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECTS_DIR="$DEVBOX_ROOT/projects"
WORKSPACE_FILE="$DEVBOX_ROOT/workspaces/devbox.code-workspace"

usage() {
  echo "Usage: $0 <git-url> [display-name]"
  echo ""
  echo "例:"
  echo "  $0 https://github.com/user/my-app.git"
  echo "  $0 https://github.com/user/my-app.git \"📦 My App\""
  exit 1
}

[[ $# -lt 1 ]] && usage

REPO_URL="$1"
REPO_NAME="$(basename "$REPO_URL" .git)"
DISPLAY_NAME="${2:-📦 $REPO_NAME}"
TARGET_DIR="$PROJECTS_DIR/$REPO_NAME"

# -------------------------------------------------------
# クローン
# -------------------------------------------------------
if [ -d "$TARGET_DIR" ]; then
  echo "⚠️  $TARGET_DIR は既に存在します。pull を実行します。"
  git -C "$TARGET_DIR" pull --rebase
else
  echo "📥 $REPO_URL をクローン中..."
  mkdir -p "$PROJECTS_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

# -------------------------------------------------------
# ワークスペースファイルへの追加
# -------------------------------------------------------
if [ -f "$WORKSPACE_FILE" ] && command -v python3 &> /dev/null; then
  python3 - "$WORKSPACE_FILE" "$REPO_NAME" "$DISPLAY_NAME" <<'PYEOF'
import json, sys

ws_path, repo_name, display_name = sys.argv[1], sys.argv[2], sys.argv[3]
with open(ws_path, "r") as f:
    ws = json.load(f)

rel_path = f"../projects/{repo_name}"
existing = [folder["path"] for folder in ws["folders"]]
if rel_path not in existing:
    ws["folders"].append({"name": display_name, "path": rel_path})
    with open(ws_path, "w") as f:
        json.dump(ws, f, indent=2, ensure_ascii=False)
    print(f"✅ ワークスペースに追加: {display_name}")
else:
    print(f"ℹ️  既にワークスペースに登録済み: {rel_path}")
PYEOF
else
  echo "ℹ️  ワークスペースファイルへの自動追加をスキップしました。"
fi

echo ""
echo "完了！プロジェクト: $TARGET_DIR"
