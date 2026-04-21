#!/usr/bin/env bash

set -euo pipefail

commit_msg_file="$1"
commit_msg="$(head -n 1 "$commit_msg_file")"

if [[ ! "$commit_msg" =~ ^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert|wip):[[:space:]].+ ]]; then
  echo "Invalid commit message format."
  echo "Expected: (feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert|wip): <commit-message>"
  echo "Got: $commit_msg"
  exit 1
fi
