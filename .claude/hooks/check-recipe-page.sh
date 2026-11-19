#!/usr/bin/env bash
# PostToolUse (Write|Edit): レシピ帳ページを編集したら、スクリプトの書き間違いを確かめる。
# 失敗したら Claude に差し戻し、成功したら公開し直すよう促す。
f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
case "$f" in
  */recipes/*.html) ;;
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
if err=$(node --check "$tmp" 2>&1); then
  jq -n --arg f "$f" '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:("レシピ帳ページのスクリプトは構文OK。変更を終えたら Artifact ツールで https://claude.ai/artifact/VSxMtTUpvH9bWUh6XBfJa6 に公開し直すこと（file_path: " + $f + "、url を指定）。")}}'
else
  jq -n --arg e "$(printf '%s' "$err" | head -n 8)" '{decision:"block",reason:("レシピ帳ページのスクリプトに構文エラーがあります。直してから公開してください:\n" + $e)}'
fi
