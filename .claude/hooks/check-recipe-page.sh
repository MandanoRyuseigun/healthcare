#!/usr/bin/env bash
# PostToolUse (Write|Edit): レシピ帳ページ（claude.ai 版）とベータ版を編集したら、スクリプトの書き間違いを確かめる。
# 失敗したら Claude に差し戻す。成功したら、次にやること（公開し直す／バージョンを上げる）を促す。
f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
case "$f" in
  */recipes/*.html) kind=artifact ;;
  */beta/*.html) kind=beta ;;
  *) exit 0 ;;
esac
[ -f "$f" ] || exit 0
command -v node >/dev/null && command -v python3 >/dev/null || exit 0
tmp=$(mktemp --suffix=.js)
trap 'rm -f "$tmp"' EXIT
python3 -I - "$f" "$tmp" <<'PY'
import re, sys
s = open(sys.argv[1], encoding="utf-8").read()
blocks = re.findall(r"<script>(.*?)</script>", s, re.S)
open(sys.argv[2], "w", encoding="utf-8").write("\n;\n".join(blocks))
PY
if ! err=$(node --check "$tmp" 2>&1); then
  jq -n --arg e "$(printf '%s' "$err" | head -n 8)" '{decision:"block",reason:("ページのスクリプトに構文エラーがあります。直してから公開してください:\n" + $e)}'
  exit 0
fi
if [ "$kind" = artifact ]; then
  jq -n --arg f "$f" '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:("レシピ帳ページのスクリプトは構文OK。変更を終えたら Artifact ツールで https://claude.ai/artifact/VSxMtTUpvH9bWUh6XBfJa6 に公開し直すこと（file_path: " + $f + "、url を指定）。")}}'
  exit 0
fi
# ベータ版：コミット済みの版と比べて APP_VERSION が上がっているか
ver() { grep -o 'APP_VERSION = "[^"]*"' | head -n 1 | cut -d'"' -f2; }
now=$(ver < "$f")
dir=$(cd "$(dirname "$f")" && pwd)
rel=$(cd "$dir" && git ls-files --full-name -- "$(basename "$f")" 2>/dev/null)
old=""
[ -n "$rel" ] && old=$(cd "$dir" && git show "HEAD:$rel" 2>/dev/null | ver)
if [ -n "$old" ] && [ "$now" = "$old" ]; then
  msg="ベータ版のスクリプトは構文OK。ただし APP_VERSION が前のコミットと同じ（$now）。利用者に見せる変更なら APP_VERSION と APP_DATE を上げ、beta/README.md の更新履歴に書くこと。"
else
  msg="ベータ版のスクリプトは構文OK（APP_VERSION: ${now:-未設定}）。beta/README.md の更新履歴にこのバージョンを書くこと。公開は利用者が Netlify の同じサイトに上書きする（アドレスを変えない）。"
fi
jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$m}}'
