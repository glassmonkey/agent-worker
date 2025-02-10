#!/bin/bash

# 引数の確認
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <pr-number> <comment-id> [message] [commit-hash]"
  echo "Example: $0 11 1948362971 \"修正しました\" abc1234"
  exit 1
fi

PR_NUMBER=$1
COMMENT_ID=$2
MESSAGE=${3:-""}
COMMIT_HASH=${4:-""}

# リポジトリ情報の取得
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)

# メッセージが指定されていない場合は入力を求める
if [ -z "$MESSAGE" ]; then
  echo "✏️  Enter your reply message:"
  read -r MESSAGE
fi

# コミットハッシュが指定されていない場合は入力を求める
if [ -z "$COMMIT_HASH" ]; then
  echo "🔍 Enter the commit hash for the fix:"
  read -r COMMIT_HASH
fi

# リプライメッセージの作成（JSONフォーマットで改行を保持）
FULL_MESSAGE="$MESSAGE\n\n修正コミット: $COMMIT_HASH"

# リプライの送信
echo "💬 Sending reply to comment $COMMENT_ID..."
echo "{\"body\": \"$FULL_MESSAGE\"}" | \
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies \
  --input -

# 返信済みコメントの記録
REPLIED_FILE=".work/replied_comments.txt"
mkdir -p .work
echo "$COMMENT_ID" >> "$REPLIED_FILE"

echo "✅ Reply sent successfully!" 