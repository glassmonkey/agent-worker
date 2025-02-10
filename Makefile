.PHONY: init install dev build test lint type-check clean help start-work finish-work end-work

# デフォルトのターゲット
.DEFAULT_GOAL := help

# 共通の変数
APP_DIR := app

# 初期化（プロジェクトの初期セットアップ）
init: ## プロジェクトの初期化を行う
	@echo "🚀 Initializing project..."
	@if ! command -v gh &> /dev/null; then \
		echo "📥 Installing GitHub CLI..."; \
		brew install gh; \
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

# 作業開始
start-work: ## 作業用ブランチを作成し、作業環境を準備する
	@if [ -z "$(branch)" ]; then \
		echo "Usage: make start-work branch=<branch-name>"; \
		echo "Example: make start-work branch=feature/add-counter"; \
		exit 1; \
	fi
	@echo "🚀 Starting work on branch: $(branch)..."
	@echo "🔄 Updating main branch..."
	@git fetch origin main
	@git switch main
	@git pull origin main
	@echo "🧹 Cleaning .work directory..."
	@rm -rf .work/*
	@echo "🌱 Creating work branch: $(branch)..."
	@git checkout -b $(branch)
	@echo "📁 Preparing .work directory..."
	@mkdir -p .work
	@echo "📝 Creating PR draft..."
	@touch .work/pr-draft.md
	@echo "✨ Work environment initialized successfully!"
	@echo "📝 PR draft created at .work/pr-draft.md"

# 作業終了
finish-work: ## PRを作成し、作業を終了する
	@if [ -z "$(title)" ]; then \
		echo "Usage: make finish-work title=<pr-title>"; \
		echo "Example: make finish-work title=\"feat: カウンター機能の追加\""; \
		exit 1; \
	fi
	@echo "🏁 Finishing work with PR title: $(title)..."
	@./scripts/finish-work.sh "$(title)"

# ヘルプの表示
help: ## このヘルプメッセージを表示する
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' 

# 作業終了
end-work:
	@echo "🔍 Checking for uncommitted changes..."
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "⚠️  You have uncommitted changes. Please commit or stash them first."; \
		exit 1; \
	fi
	@echo "🧹 Cleaning .work directory..."
	@rm -rf .work/*
	@echo "🔄 Switching to main branch..."
	@git switch main
	@echo "✨ Work completed successfully!"
