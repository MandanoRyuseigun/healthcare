# healthcare リポジトリ

## うちのレシピ帳

料理のレシピ提案・調節・「うちのレシピ帳」への登録/閲覧を頼まれたら `recipes/README.md` を読むこと。
レシピ帳は https://claude.ai/artifact/VSxMtTUpvH9bWUh6XBfJa6 。レシピは人ごとに `data/users/me/book/recipes`、公開分は `shared/<ユーザーID>`（`ArtifactData` で読み書き）。
登録は提案内容をユーザーが確認してから。既存レシピの変更は `if_version` を付ける。
