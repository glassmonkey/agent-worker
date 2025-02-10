.PHONY: init install dev build test lint type-check clean help

# デフォルトのターゲット
.DEFAULT_GOAL := help

# 共通の変数
APP_DIR := app

# 初期化（プロジェクトの初期セットアップ）
init: ## プロジェクトの初期化を行う
	@echo "🚀 Initializing project..."
	@if ! command -v gh &> /dev/null; then \
		echo "📥 Installing GitHub CLI..."; \
		if [ "$(uname)" = "Darwin" ]; then \
			brew install gh; \
		elif [ -f /etc/debian_version ]; then \
			type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y); \
			curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
			&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
			&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
			&& sudo apt update \
			&& sudo apt install gh -y; \
		elif [ -f /etc/redhat-release ]; then \
			sudo dnf install 'dnf-command(config-manager)' -y; \
			sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo; \
			sudo dnf install gh -y; \
		fi; \
	fi
	@cd $(APP_DIR) && npm install
	@cd $(APP_DIR) && npm run prepare
	@echo "✨ Project initialized successfully!"

# 依存関係のインストール
install: ## 依存関係をインストールする
	@echo "📦 Installing dependencies..."
	@cd $(APP_DIR) && npm install

# 開発サーバーの起動
dev: ## 開発サーバーを起動する
	@echo "🔥 Starting development server..."
	@cd $(APP_DIR) && npm run dev

# プロダクションビルド
build: ## プロダクションビルドを実行する
	@echo "🏗️  Building for production..."
	@cd $(APP_DIR) && npm run build

# テストの実行
test: ## テストを実行する
	@echo "🧪 Running tests..."
	@cd $(APP_DIR) && npm run test

# リントの実行
lint: ## リントを実行する
	@echo "🔍 Running linter..."
	@cd $(APP_DIR) && npm run lint

# 型チェックの実行
type-check: ## 型チェックを実行する
	@echo "✅ Running type check..."
	@cd $(APP_DIR) && npm run type-check

# クリーンアップ
clean: ## ビルドファイルとキャッシュを削除する
	@echo "🧹 Cleaning up..."
	@cd $(APP_DIR) && rm -rf .next out node_modules
	@echo "✨ Cleanup completed!"

# ヘルプの表示
help: ## このヘルプメッセージを表示する
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' 
