# うちのレシピ帳

- ページ: https://claude.ai/artifact/VSxMtTUpvH9bWUh6XBfJa6
- レシピはページ側のデータベース（コレクション `recipes`）に保存され、このリポジトリには含まれない
- ページの機能: 検索・カテゴリ/お気に入りの絞り込み、詳細表示、手入力での追加・編集・削除、ページ内の「提案してもらう」

## チャットでの使い方

- 「◯◯で作れる夕飯を提案して」→ Claude がレシピを提案
- 「3人分にして」「減塩にして」「豚肉に変えて」→ 調節
- 「レシピ帳に登録して」→ 内容を確認してもらってから `ArtifactData` で `recipes` に書き込む
- 「レシピ帳の◯◯を見せて／直して」→ 読み出して表示・更新（更新は読んだ version を `if_version` に指定）

## `recipes/<doc_id>` のデータ形式（ページのコードに合わせること）

doc_id は英数字とハイフン（例 `torimune-shoga-itame`）。

| フィールド | 型 | 内容 |
|---|---|---|
| name | string | 料理名（必須、80字まで） |
| category | string | `主菜` / `副菜` / `汁物` / `ご飯・麺` / `おやつ` / `作り置き` のどれか |
| minutes | number | 調理時間（分） |
| servings | number | 何人分 |
| kcal | number | 1人分のおおよその kcal |
| ingredients | {item, amount}[] | amount は文字列（「大さじ1」「300g」「少々」） |
| steps | string[] | 作り方（4〜8手順が目安） |
| tags | string[] | 例: 時短, ヘルシー, 高たんぱく, 作り置き向き, 走る前の補給, 走った後の回復, 子どもも喜ぶ |
| note | string | コツ・保存方法など |
| favorite | boolean | お気に入り（新規は false） |
| source | string | `claude`（チャットで登録）/ `ai`（ページ内の提案）/ `manual`（手入力） |
| createdAt | number | ミリ秒の Unix 時刻。一覧はこの新しい順なので必須 |
| updatedAt | number | 更新時のミリ秒の Unix 時刻 |
