#!/bin/bash

# 引数の確認
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <comment-id> <message> [include_commit]"
  echo "Example: $0 1948362971 \"修正しました\" true"
  exit 1
fi

COMMENT_ID=$1
MESSAGE=$2
INCLUDE_COMMIT=${3:-false}

# リポジトリ情報の取得
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)
PR_NUMBER=$(gh pr view --json number -q .number)

# リプライメッセージの作成（JSONフォーマットで改行を保持）
if [ "$INCLUDE_COMMIT" = "true" ]; then
  # 最新のコミットハッシュを取得
  COMMIT_HASH=$(git rev-parse HEAD)
  COMMIT_URL="https://github.com/$OWNER/$REPO/commit/$COMMIT_HASH"
  FULL_MESSAGE="$MESSAGE\n\n修正コミット: $COMMIT_URL"
else
  FULL_MESSAGE="$MESSAGE"
fi

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