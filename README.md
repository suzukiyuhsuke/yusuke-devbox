# yusuke-devbox

GitHub Codespaces 上で動作する個人開発環境（DevBox）です。

## リポジトリの目的

このリポジトリは、GitHub Codespaces を活用した **再現可能な個人開発環境** を提供します。

- 開発ツール・拡張機能・設定を一元管理し、どの端末からでも同じ環境を即座に立ち上げられる
- Dev Container 設定により、チーム間での環境共有やオンボーディングにも対応
- 複数プロジェクトを横断して作業できる Multi-root Workspace をサポート

## 想定利用シナリオ

| シナリオ | 説明 |
|---|---|
| **日常開発** | Python / Node.js / .NET など複数言語のプロジェクトを Codespaces 上でシームレスに切り替えながら開発 |
| **AI/ML プロトタイピング** | Azure AI Foundry や OpenAI SDK を使った実験・検証を素早く開始 |
| **インフラ管理** | Terraform / Bicep によるクラウドインフラのコード化と検証 |
| **ドキュメント執筆** | Markdown / MkDocs を使った技術ドキュメントの作成とプレビュー |
| **学習・実験** | 新しい技術やライブラリの検証を隔離された環境で安全に実施 |

## 推奨ディレクトリ構成

```
yusuke-devbox/
├── .devcontainer/          # Dev Container 設定
│   ├── devcontainer.json   # メイン設定ファイル
│   ├── Dockerfile          # カスタムイメージ定義（必要に応じて）
│   └── post-create.sh      # 環境構築後の初期化スクリプト
├── .vscode/                # VS Code 共通設定
│   ├── settings.json       # エディタ設定
│   └── extensions.json     # 推奨拡張機能
├── projects/               # 個別プロジェクト群（Multi-root Workspace 対象）
│   ├── project-alpha/
│   ├── project-beta/
│   └── ...
├── scripts/                # ユーティリティスクリプト
│   ├── setup.sh            # 初回セットアップ
│   └── update-tools.sh     # ツール更新
├── dotfiles/               # 個人設定ファイル（シェル設定など）
│   ├── .bashrc
│   ├── .gitconfig
│   └── .aliases
├── workspaces/             # VS Code ワークスペースファイル
│   └── devbox.code-workspace
├── docs/                   # ドキュメント・ナレッジベース
├── README.md
└── .gitignore
```

## Multi-root Workspace 利用方法

Multi-root Workspace を使うことで、複数のプロジェクトを 1 つの VS Code ウィンドウで同時に扱えます。

### ワークスペースファイルの作成

`workspaces/devbox.code-workspace` に以下のような構成で定義します:

```jsonc
{
  "folders": [
    {
      "name": "🏠 DevBox Root",
      "path": ".."
    },
    {
      "name": "📦 Project Alpha",
      "path": "../projects/project-alpha"
    },
    {
      "name": "📦 Project Beta",
      "path": "../projects/project-beta"
    }
  ],
  "settings": {
    "files.exclude": {
      "**/node_modules": true,
      "**/__pycache__": true
    }
  }
}
```

### Codespaces での利用手順

1. Codespaces を起動する
2. ターミナルで以下を実行してワークスペースを開く:
   ```bash
   code workspaces/devbox.code-workspace
   ```
3. 各プロジェクトフォルダが左側のエクスプローラーにルートとして表示される

### プロジェクトの追加

新しいプロジェクトを追加する場合:

```bash
# projects/ ディレクトリにクローン
cd projects/
git clone https://github.com/your-org/new-project.git

# ワークスペースファイルに追記
# workspaces/devbox.code-workspace の "folders" 配列に追加
```

> **Tips:** `projects/` 配下の各リポジトリは `.gitignore` で除外し、サブモジュールとして管理するか、起動スクリプトでクローンする運用を推奨します。

## Azure AI Foundry 開発での利用例

Azure AI Foundry を使った AI アプリケーション開発のワークフロー例です。

### 前提条件

- Azure サブスクリプション
- Azure AI Foundry ハブ & プロジェクトの作成済み
- Azure CLI (`az`) の認証済み

### 環境セットアップ

```bash
# Azure CLI でログイン
az login

# AI Foundry 用 Python パッケージのインストール
pip install azure-ai-projects azure-identity azure-ai-inference

# 環境変数の設定（.env ファイルまたは Codespaces Secrets を推奨）
export AZURE_AI_PROJECT_CONNECTION_STRING="your-connection-string"
```

### プロジェクト構成例

```
projects/
└── ai-foundry-app/
    ├── src/
    │   ├── main.py              # エントリーポイント
    │   ├── agents/              # AI エージェント定義
    │   │   └── assistant.py
    │   └── tools/               # カスタムツール
    │       └── search_tool.py
    ├── prompts/                 # プロンプトテンプレート
    │   └── system_prompt.md
    ├── tests/                   # テストコード
    ├── .env.sample              # 環境変数テンプレート
    └── requirements.txt
```

### AI エージェント開発の基本フロー

```python
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient

# プロジェクトクライアントの初期化
project_client = AIProjectClient.from_connection_string(
    credential=DefaultAzureCredential(),
    conn_str=os.environ["AZURE_AI_PROJECT_CONNECTION_STRING"],
)

# チャット補完の利用
chat = project_client.inference.get_chat_completions_client()
response = chat.complete(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"},
    ],
)
print(response.choices[0].message.content)
```

### Codespaces Secrets の活用

機密情報は Codespaces Secrets で管理します:

1. GitHub リポジトリの **Settings → Secrets and variables → Codespaces** を開く
2. 以下のシークレットを登録:
   - `AZURE_AI_PROJECT_CONNECTION_STRING`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`
3. Codespaces 内では自動的に環境変数として利用可能

---

> **注意:** このリポジトリは個人の開発環境であり、機密情報やクレデンシャルをコミットしないよう注意してください。`.env` ファイルは必ず `.gitignore` に含めてください。

## ランタイムのバージョン管理

各言語のバージョン更新方法をまとめます。

| 言語 | バージョンマネージャー | コンテナ内での更新 | Rebuild時の挙動 |
|---|---|---|---|
| Node.js | nvm | `nvm install --lts && nvm alias default lts/*` | 最新 LTS を自動取得 |
| Rust | rustup | `rustup update` | 安定版を自動取得 |
| Python | devcontainer feature | Rebuild が必要 | 最新版を自動取得 |
| C# / .NET | devcontainer feature | Rebuild が必要 | 最新 LTS を自動取得 |
| Java | SDKMAN | `sdk update java` | 最新 LTS を自動取得 |

> Rebuild は VS Code コマンドパレットから **Dev Containers: Rebuild Container** を実行します。
