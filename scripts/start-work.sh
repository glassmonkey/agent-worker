#!/bin/bash

# エラーが発生したら即座に終了
set -e

# 引数の確認
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <branch-name>"
  echo "Example: $0 feature/add-counter"
  exit 1
fi

BRANCH_NAME=$1

# mainブランチの更新
echo "🔄 Updating main branch..."
git fetch origin main
git switch main
git pull origin main

# .workディレクトリの掃除
echo "🧹 Cleaning .work directory..."
rm -rf .work/*

# 作業用ブランチの作成
echo "🌱 Creating work branch: $BRANCH_NAME..."
git checkout -b "$BRANCH_NAME"

# .workディレクトリの準備
echo "📁 Preparing .work directory..."
mkdir -p .work

# PR説明のドラフトを作成
echo "📝 Creating PR draft..."
cat > .work/pr-draft.md << EOL
## 概要
<!-- PRの目的、背景、変更点を簡潔に記載してください -->




## 変更内容
<!-- 具体的な変更内容をリストアップしてください -->




## 確認したこと
<!-- 動作確認やテストの内容を記載してください -->
- [ ] 単体テストを実行した
- [ ] 動作確認を実行した
- [ ] リンター/型チェックを実行した

### 動作確認の内容
<!-- 実施した動作確認の詳細を記載してください -->




## 補足
<!-- レビュアーへの注意点や補足事項があれば記載してください --> 
EOL

echo "✨ Work environment initialized successfully!"
echo "📝 PR draft created at .work/pr-draft.md" 