#!/bin/bash
input=$(cat)

MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PERCENT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

GIT_BRANCH=$(git -C "$CURRENT_DIR" --no-optional-locks branch --show-current 2>/dev/null)
BRANCH_PART=""
[ -n "$GIT_BRANCH" ] && BRANCH_PART=" ($GIT_BRANCH)"

echo "$MODEL_DISPLAY${BRANCH_PART} 📁 ${PERCENT_USED}%"
