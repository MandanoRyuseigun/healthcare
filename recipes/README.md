# うちのレシピ帳

- 公開ページ: https://claude.ai/artifact/RR3T5WMfiRFcHSkBTyGfYN
- ソース: `recipe-book.html`（Artifact として公開。capabilities は `db`）
- レシピ本体はページ側のデータベース（コレクション `recipes`）に保存され、このリポジトリには含まれない

## チャットでの使い方

- 「◯◯で作れる夕飯を提案して」→ Claude がレシピを提案
- 「3人分にして」「減塩にして」「豚肉に変えて」→ 調節
- 「レシピ帳に登録して」→ `ArtifactData` で `recipes` に書き込む
- 「レシピ帳の◯◯を見せて／直して」→ 読み出して表示・更新（更新は読んだ version を `if_version` に指定）

## `recipes/<doc_id>` のデータ形式

doc_id は料理名をローマ字にした英数字とハイフン（例 `torimune-komatsuna-shoga`）。ページの URL `#r-<doc_id>` でそのレシピが開く。

| フィールド | 型 | 内容 |
|---|---|---|
| title | string | 料理名（必須） |
| kana | string | 読み（検索用） |
| category | string | 主菜 / 副菜 / 汁物 / 主食 / 作り置き / おやつ / その他 |
| tags | string[] | 例: 高たんぱく, 20分以内, 減塩 |
| summary | string | ひとこと説明 |
| servings | number | 基準の人数（ページで人数を変えると分量を再計算） |
| timeMin | number | 調理時間（分） |
| ingredients | {name, qty, unit, note?, group?}[] | qty は数値。「少々」「適量」は qty を null、unit にその語。大さじ・小さじ・カップは自動で「大さじ1と1/2」表記 |
| steps | string[] | 作り方 |
| tips | string | コツ・アレンジ（改行可） |
| nutrition | {kcal, protein, salt} | 1人分の目安 |
| source | string | 出どころ（例: Claudeの提案、母のレシピ） |
| favorite | boolean | お気に入り（ページで切替） |
| cookedCount / lastCooked | number / "YYYY-MM-DD" | 「今日作った」ボタンで更新 |
| memo | string | うちのメモ（ページで編集） |
| createdAt / updatedAt | ISO 8601 | 一覧は createdAt の新しい順 |
