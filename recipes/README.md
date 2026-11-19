# うちのレシピ帳

- ページ: https://claude.ai/artifact/VSxMtTUpvH9bWUh6XBfJa6
- レシピはページ側のデータベースに、人ごとに分けて保存され、このリポジトリには含まれない
- 1人ずつ自分専用のレシピ帳。ほかの人のレシピは「みんなのレシピ」に公開されたものだけ見える
- ページの機能: 検索・カテゴリ/お気に入りの絞り込み、詳細表示、手入力での追加・編集・削除、ページ内の「提案してもらう」、レシピごとの「AIに相談」（相談の記録・メモに追加・レシピに反映）、「うちの調理環境」の保存

## チャットでの使い方

- 「◯◯で作れる夕飯を提案して」→ Claude がレシピを提案
- 「3人分にして」「減塩にして」「豚肉に変えて」→ 調節
- 「レシピ帳に登録して」→ 内容を確認してもらってから `ArtifactData` で `data/users/me/book/recipes` に書き込む（`me` は頼んだ本人）
- 「レシピ帳の◯◯を見せて／直して」→ 読み出して表示・更新（更新は読んだ version を `if_version` に指定）

## `data/users/me/book/recipes/<doc_id>` のデータ形式（ページのコードに合わせること）

doc_id は英数字とハイフン（例 `torimune-shoga-itame`）。

| フィールド | 型 | 内容 |
|---|---|---|
| name | string | 料理名（必須、80字まで） |
| category | string | `主菜` / `副菜` / `汁物` / `ご飯・麺` / `おやつ` / `作り置き` のどれか（下の「カテゴリの決め方」） |
| minutes | number | 調理時間（分） |
| servings | number | 何人分 |
| kcal | number | 1人分のおおよその kcal |
| ingredients | {item, amount}[] | amount は文字列（「大さじ1」「300g」「少々」） |
| steps | string[] | 作り方（4〜8手順が目安） |
| tags | string[] | 例: 時短, ヘルシー, 高たんぱく, 作り置き向き, 走る前の補給, 走った後の回復, 子どもも喜ぶ |
| note | string | コツ・保存方法など |
| favorite | boolean | お気に入り（新規は false） |
| source | string | `claude`（チャットで登録）/ `ai`（ページ内の提案）/ `manual`（手入力）/ `shared`（みんなのレシピから保存） |
| sharedFrom | string | `shared` のとき、公開した人のユーザーID |
| shopping | {item, amount, price, why, without, store, storeDays}[] | 買い足すもの（任意）。price はおおよその円、why は買う理由、without は買わずに作る方法、store は残った分の保存方法、storeDays は保存期間の目安（例「冷蔵2〜3日・冷凍1か月」） |
| budget | number \| "free" | 提案時の買い足し予算（円）。0 は買い足さない、"free" は気にしない（任意） |
| createdAt | number | ミリ秒の Unix 時刻。一覧はこの新しい順なので必須 |
| updatedAt | number | 更新時のミリ秒の Unix 時刻 |

## カテゴリの決め方

- 主菜：肉・魚・卵・大豆製品などが中心の、ご飯と一緒に食べるメインのおかず。ご飯もの・丼・麺類・パン・粉もの（お好み焼きなど）は入れない
- 副菜：野菜・きのこ・海藻・いもなどが中心の小さなおかず
- 汁物：味噌汁・スープ・豚汁など。麺類は入れない
- ご飯・麺：ご飯もの・丼・炊き込みご飯・おにぎり・うどん・そば・パスタなどの麺類・パン
- おやつ：間食やデザート
- 作り置き：冷蔵や冷凍で数日もつ常備菜

「主菜を提案して」と言われたら、うどんや丼などの「ご飯・麺」の料理は出さない。

## そのほかのデータ

- `data/users/me/book/recipes/<doc_id>/advice/<id>` … レシピごとの「AIに相談」の記録 `{q, a, createdAt(ミリ秒)}`。古い順に表示
- `data/users/me/kitchen` … うちの調理環境 `{equipment, pantry, updatedAt}`。equipment は調理器具・設備、pantry はいつも家にある食材・調味料（どちらも自由記述）

チャットで提案・相談するときも、まず `data/users/me/kitchen` を読んで、その器具で作れるレシピにし、家にある食材・調味料を活かす。
「グリルを買った」「圧力鍋はない」など環境の話が出たら、確認してから `data/users/me/kitchen` を更新する。

## 買い足しの判断

提案のときは、家にある食材と `data/users/me/kitchen` の常備品にないものを、買い足し予算の範囲で買うか考える。
買わなくてもおいしく作れるならそちらを優先し、買う場合は `shopping` におおよその値段・買う理由・買わずに作る方法を入れる。合計が予算をこえないようにする。
買い足すものには、残った分の保存方法（store）と保存期間の目安（storeDays）も必ず入れる。
チャットで予算が分からないときは聞く。

## みんなのレシピ（公開）

- `shared/<ユーザーID>` に、その人が公開したレシピを `{recipes: {<自分のレシピの doc_id>: {name, category, ..., publishedAt, updatedAt}}, updatedAt}` の形でまとめて持つ
- 公開されるのは name, category, minutes, servings, kcal, ingredients, steps, tags, note, shopping, budget。相談の記録・お気に入り・調理環境は公開しない
- 書き込めるのは本人の `shared/<自分のID>` だけ。ページの持ち主は全員分を削除できる（不適切な投稿の取り下げ用）
- 公開は本人がページのボタンで行う。チャットから公開・取り下げをするのは、本人にはっきり頼まれたときだけ
