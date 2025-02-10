.PHONY: init install dev build test lint type-check clean help update-main push

# デフォルトのターゲット
.DEFAULT_GOAL := help

# 共通の変数
APP_DIR := app

# mainブランチの更新
update-main: ## mainブランチを最新に更新する
	@echo "🔄 Updating main branch..."
	@git fetch origin main
	@git switch main
	@git pull origin main
	@git switch -

# プッシュ（mainブランチの更新を含む）
push: update-main ## 変更をプッシュする（mainブランチの更新を含む）
	@echo "⬆️  Pushing changes..."
	@git push

# 初期化（プロジェクトの初期セットアップ）
init: ## プロジェクトの初期化を行う
	@echo "🚀 Initializing project..."
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