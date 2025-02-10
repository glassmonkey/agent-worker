# デフォルトのターゲット
.DEFAULT_GOAL := help

# 共通の変数
APP_DIR := app

.PHONY: init
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

.PHONY: install
# 依存関係のインストール
install: ## 依存関係をインストールする
	@echo "📦 Installing dependencies..."
	@cd $(APP_DIR) && npm install

.PHONY: dev
# 開発サーバーの起動
dev: ## 開発サーバーを起動する
	@echo "🔥 Starting development server..."
	@cd $(APP_DIR) && npm run dev

.PHONY: build
# プロダクションビルド
build: ## プロダクションビルドを実行する
	@echo "🏗️  Building for production..."
	@cd $(APP_DIR) && npm run build

.PHONY: test
# テストの実行
test: ## テストを実行する
	@echo "🧪 Running tests..."
	@cd $(APP_DIR) && npm run test

.PHONY: lint
# リントの実行
lint: ## リントを実行する
	@echo "🔍 Running linter..."
	@cd $(APP_DIR) && npm run lint

.PHONY: type-check
# 型チェックの実行
type-check: ## 型チェックを実行する
	@echo "✅ Running type check..."
	@cd $(APP_DIR) && npm run type-check

.PHONY: clean
# クリーンアップ
clean: ## ビルドファイルとキャッシュを削除する
	@echo "🧹 Cleaning up..."
	@cd $(APP_DIR) && rm -rf .next out node_modules
	@echo "✨ Cleanup completed!"

.PHONY: start-work
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

.PHONY: submit-work
# PR作成
submit-work: ## 作業内容をプッシュしてPRを作成する
	@if [ -z "$(title)" ]; then \
		echo "Usage: make submit-work title=<pr-title>"; \
		echo "Example: make submit-work title=\"feat: カウンター機能の追加\""; \
		exit 1; \
	fi
	@echo "🏁 Submitting work with PR title: $(title)..."
	@if [ ! -f .work/pr-draft.md ]; then \
		echo "⚠️  PR draft file not found at .work/pr-draft.md"; \
		exit 1; \
	fi
	@echo "🔍 Checking for uncommitted changes..."
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "⚠️  You have uncommitted changes. Please commit or stash them first."; \
		exit 1; \
	fi
	@echo "🚀 Pushing changes..."
	@BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	git push origin $$BRANCH
	@echo "📤 Creating PR..."
	@gh pr create --repo $$(git remote get-url origin | sed 's/.*://; s/\.git$$//') --title "$(title)" --body-file .work/pr-draft.md
	@echo "✨ PR created successfully!"
	@echo "👀 Starting PR monitoring..."
	@$(MAKE) monitor-pr

.PHONY: finish-work
# 作業完了
finish-work: ## レビュー通過後の作業を完了する
	@echo "🔍 Checking PR status..."
	@./scripts/monitor-pr.sh --check-only || exit 1
	@echo "🧹 Cleaning .work directory..."
	@rm -rf .work/*
	@echo "🔄 Switching to main branch..."
	@git switch main
	@echo "🔄 Updating main branch..."
	@git pull origin main
	@echo "🗑️  Deleting work branch..."
	@git branch -d $$(git rev-parse --abbrev-ref HEAD)
	@echo "✨ Work completed successfully!"

.PHONY: monitor-pr
# レビューの監視
monitor-pr: ## PRのレビュー状態とCIを監視する
	@echo "👀 Monitoring PR status..."
	@./scripts/monitor-pr.sh

.PHONY: reply-to-review
# レビューコメントへの返信
reply-to-review: ## レビューコメントに返信する
	@if [ -z "$(comment_id)" ] || [ -z "$(message)" ]; then \
		echo "Usage: make reply-to-review comment_id=<comment_id> message=<message> [include_commit=true]"; \
		echo "Example: make reply-to-review comment_id=123456789 message=\"修正しました。\" include_commit=true"; \
		exit 1; \
	fi
	@echo "💬 Replying to comment $(comment_id)..."
	@./scripts/reply-to-review.sh $(comment_id) "$(message)" $(include_commit)
	@echo "✨ Reply sent successfully!"

.PHONY: help
# ヘルプの表示
help: ## このヘルプメッセージを表示する
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' 
