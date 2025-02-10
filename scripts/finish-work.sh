#!/bin/bash

# エラーが発生したら即座に終了
set -e

# 引数の確認
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <pr-title>"
  echo "Example: $0 \"feat: カウンター機能の追加\""
  exit 1
fi

PR_TITLE=$1

# 現在のブランチ名を取得
CURRENT_BRANCH=$(git branch --show-current)

# mainブランチの最新変更を取り込む
echo "🔄 Updating from main branch..."
git fetch origin main
git rebase main

# 型チェック、リント、テストを実行
echo "🔍 Running checks..."
cd app && npm run type-check
npm run lint
npm run test
cd ..

# コミットの整理を促す
echo "📝 Please organize your commits if needed:"
echo "1. Check your commits with: git log"
echo "2. Organize commits with: git rebase -i main"
echo "3. Press Enter when ready"
read -r

# 変更内容を確認
echo "🔍 Reviewing changes..."
git diff main

# プッシュの確認
echo "❓ Ready to push changes? [y/N]"
read -r CONFIRM
if [[ $CONFIRM =~ ^[Yy]$ ]]; then
  echo "🚀 Pushing changes..."
  git push origin "$CURRENT_BRANCH" --force-with-lease
else
  echo "❌ Push cancelled"
  exit 1
fi

# PRの作成
if [ -f .work/pr-draft.md ]; then
  echo "📝 Creating pull request..."
  gh pr create --title "$PR_TITLE" --body-file .work/pr-draft.md
else
  echo "⚠️ PR draft not found at .work/pr-draft.md"
  exit 1
fi

# PRの監視を開始
echo "👀 Starting PR monitoring..."
./scripts/monitor-pr.sh

# 終了コード
# 0: 正常終了
# 1: エラー発生

echo "🧹 Starting post-merge cleanup..."

# mainブランチに切り替え
echo "🔄 Switching to main branch..."
git switch main || {
  echo "❌ Failed to switch to main branch"
  exit 1
}

# mainブランチを最新に更新
echo "🔄 Updating main branch..."
git pull origin main || {
  echo "❌ Failed to update main branch"
  exit 1
}

# 作業ブランチの取得
WORK_BRANCH=$(git branch --show-current)
if [ "$WORK_BRANCH" != "main" ]; then
  # 作業ブランチの削除
  echo "🗑️  Deleting work branch..."
  git branch -d "$WORK_BRANCH" || {
    echo "❌ Failed to delete work branch"
    exit 1
  }
fi

# .workディレクトリの掃除
echo "🧹 Cleaning up .work directory..."
rm -rf .work/* || {
  echo "❌ Failed to clean .work directory"
  exit 1
}

echo "✨ Post-merge cleanup completed successfully!"
exit 0 
