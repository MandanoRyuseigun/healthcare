#!/usr/bin/env bash
# Stop: クラウドの作業環境は時間がたつと消えるので、コミットしていない変更があれば知らせる。
input=$(cat)
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
changes=$(git status --porcelain -- recipes CLAUDE.md .claude README.md marathon 2>/dev/null)
[ -z "$changes" ] && exit 0
jq -n --arg c "$changes" '{decision:"block",reason:("コミットしていない変更があります。ユーザーが頼んだ作業の一部なら、作業ブランチにコミットしてプッシュしてください。まだ途中なら、そのことをユーザーに伝えてください:\n" + $c)}'
