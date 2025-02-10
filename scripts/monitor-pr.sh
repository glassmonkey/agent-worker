#!/bin/bash

# 終了コード
# 0: すべてのチェックが通過し、マージ可能
# 1: CIが失敗
# 2: 未解決のレビューコメントあり
# 3: コンフリクトあり
# 4: その他のエラー

# 引数からPR番号を取得
PR_NUMBER=${1:-$(gh pr view --json number -q .number)}
if [ -z "$PR_NUMBER" ]; then
  echo "❌ PR number is required"
  exit 4
fi

OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)

echo "🔍 Checking PR #$PR_NUMBER status..."

# PRの状態を確認
PR_STATUS=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr_number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr_number) {
        state
        mergeable
        reviewDecision
        commits(last: 1) {
          nodes {
            commit {
              statusCheckRollup {
                state
              }
            }
          }
        }
        reviewThreads(first: 100) {
          nodes {
            isResolved
            comments(first: 1) {
              nodes {
                body
                databaseId
              }
            }
          }
        }
      }
    }
  }
' -F owner=$OWNER -F repo=$REPO -F pr_number=$PR_NUMBER)

# PRの状態を解析
PR_STATE=$(echo "$PR_STATUS" | jq -r '.data.repository.pullRequest.state')
if [ "$PR_STATE" = "MERGED" ]; then
  echo "✨ PR #$PR_NUMBER has been merged"
  git switch main
  git pull origin main
  rm -rf .work/*
  exit 0
elif [ "$PR_STATE" = "CLOSED" ]; then
  echo "❌ PR #$PR_NUMBER has been closed"
  exit 4
fi

# マージ可能状態を確認
MERGEABLE=$(echo "$PR_STATUS" | jq -r '.data.repository.pullRequest.mergeable')
if [ "$MERGEABLE" = "CONFLICTING" ]; then
  echo "⚠️  PR has conflicts that need to be resolved"
  exit 3
fi

# CIの状態を確認
CI_STATUS=$(echo "$PR_STATUS" | jq -r '.data.repository.pullRequest.commits.nodes[0].commit.statusCheckRollup.state')
echo "🔄 CI Status: $CI_STATUS"
if [ "$CI_STATUS" = "FAILURE" ]; then
  echo "❌ CI checks have failed"
  exit 1
fi

# 未解決のレビューコメントを確認
UNRESOLVED_THREADS=$(echo "$PR_STATUS" | jq -r '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)')
if [ ! -z "$UNRESOLVED_THREADS" ]; then
  echo "⚠️  There are unresolved review comments:"
  echo "$UNRESOLVED_THREADS" | jq -r '.comments.nodes[0].body'
  echo "Comment ID: $(echo "$UNRESOLVED_THREADS" | jq -r '.comments.nodes[0].databaseId')"
  exit 2
fi

# すべてのチェックが通過
if [ "$CI_STATUS" = "SUCCESS" ]; then
  echo "✅ All checks passed. PR is ready to be merged"
  exit 0
else
  echo "⏳ Waiting for CI checks to complete"
  exit 1
fi

# レビューコメントに返信する関数
reply_to_comment() {
  local COMMENT_ID=$1
  local REPLY_MESSAGE=$2
  
  echo "💬 Replying to comment $COMMENT_ID..."
  echo "{\"body\": \"$REPLY_MESSAGE\"}" | \
  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    /repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies \
    --input -
}

# レビューコメントを取得する関数
get_review_comments() {
  gh api graphql -f query='
    query($owner: String!, $repo: String!, $pr_number: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $pr_number) {
          reviews(first: 100) {
            nodes {
              comments(first: 100) {
                nodes {
                  id
                  databaseId
                  body
                  state
                }
              }
            }
          }
        }
      }
    }
  ' -F owner=$OWNER -F repo=$REPO -F pr_number=$PR_NUMBER
}

echo "🔍 Monitoring PR #$PR_NUMBER for comments and CI status..."

while true; do
  # PRの状態を確認
  PR_STATUS=$(gh api graphql -f query='
    query($owner: String!, $repo: String!, $pr_number: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $pr_number) {
          state
          reviewDecision
          reviews(first: 100) {
            nodes {
              state
              comments(first: 100) {
                nodes {
                  body
                  state
                  databaseId
                }
              }
            }
          }
          commits(last: 1) {
            nodes {
              commit {
                statusCheckRollup {
                  state
                }
              }
            }
          }
        }
      }
    }
  ' -F owner=$OWNER -F repo=$REPO -F pr_number=$PR_NUMBER)

  # PRがマージまたはクローズされているか確認
  PR_STATE=$(echo "$PR_STATUS" | jq -r '.data.repository.pullRequest.state')
  if [ "$PR_STATE" = "MERGED" ] || [ "$PR_STATE" = "CLOSED" ]; then
    echo "✨ PR #$PR_NUMBER has been $PR_STATE. Monitoring complete."
    break
  fi

  # CIの状態を確認
  CI_STATUS=$(echo "$PR_STATUS" | jq -r '.data.repository.pullRequest.commits.nodes[0].commit.statusCheckRollup.state')
  echo "🔄 CI Status: $CI_STATUS"

  # レビューコメントを確認
  COMMENTS=$(echo "$PR_STATUS" | jq -r '.data.repository.pullRequest.reviews.nodes[] | select(.comments.nodes[].state == "SUBMITTED") | .comments.nodes[] | {body: .body, id: .databaseId}')
  
  if [ ! -z "$COMMENTS" ]; then
    echo "$COMMENTS" | jq -c '.' | while read -r comment; do
      COMMENT_BODY=$(echo "$comment" | jq -r '.body')
      COMMENT_ID=$(echo "$comment" | jq -r '.id')
      
      # コメントIDを一時ファイルから確認
      REPLIED_FILE=".work/replied_comments.txt"
      if [ ! -f "$REPLIED_FILE" ]; then
        touch "$REPLIED_FILE"
      fi
      
      # まだ返信していないコメントの場合
      if ! grep -q "^$COMMENT_ID$" "$REPLIED_FILE"; then
        echo "📝 New comment found: $COMMENT_BODY"
        echo "💭 Would you like to reply to this comment? (y/n)"
        read -r REPLY
        if [ "$REPLY" = "y" ]; then
          echo "✏️  Enter your reply message:"
          read -r MESSAGE
          echo "🔍 Enter the commit hash for the fix:"
          read -r COMMIT_HASH
          FULL_MESSAGE="$MESSAGE\n\n修正コミット: $COMMIT_HASH"
          reply_to_comment "$COMMENT_ID" "$FULL_MESSAGE"
          echo "$COMMENT_ID" >> "$REPLIED_FILE"
        fi
      fi
    done
  fi

  echo "💤 Waiting for 30 seconds..."
  sleep 30
done

# PRがマージされた場合、mainブランチに切り替えて更新
if [ "$PR_STATE" = "MERGED" ]; then
  echo "🔄 Switching to main branch and updating..."
  git switch main
  git pull origin main
  echo "🧹 Cleaning up .work directory..."
  rm -rf .work/*
  echo "✅ All done!"
fi 