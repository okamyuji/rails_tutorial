# 第3章: RESTfulなルーティングとコントローラ設計

第2章のActiveRecordモデルをベースに、RESTfulルーティングとコントローラを実装したサンプルアプリです。

## セットアップ

```bash
cd 03_routing_controllers
bundle install
bin/rails db:prepare
bin/rails db:seed
```

## 起動

```bash
bin/rails server
```

ブラウザで http://localhost:3000 を開くと記事一覧が表示されます。

## ルーティング構成

```ruby
resources :articles do
  resources :comments, shallow: true
end
```

`bin/rails routes`で生成されるルートの一部を示します。

```text
GET    /articles                         articles#index
POST   /articles                         articles#create
GET    /articles/:id                     articles#show
PATCH  /articles/:id                     articles#update
DELETE /articles/:id                     articles#destroy
GET    /articles/:article_id/comments    comments#index
POST   /articles/:article_id/comments    comments#create
GET    /comments/:id                     comments#show
PATCH  /comments/:id                     comments#update
DELETE /comments/:id                     comments#destroy
```

`shallow: true`により、コメントの一覧と作成は記事配下にネストされ、個別操作はコメントIDだけで完結します。

## コントローラの設計方針

`ApplicationController`で共通のエラーハンドリングを定義しています。

- `ActiveRecord::RecordNotFound` -> 404
- `ActionController::ParameterMissing` -> 400
- `ActiveRecord::RecordInvalid` -> 422

`respond_to`によりHTMLとJSONの両方に対応するフルスタックMVC構成です。

HTMLフォームでは`save` + if/elseでエラー時にフォームを再描画します。JSON APIでは`save!` + `rescue_from`でエラーハンドリングを集約できます。

## curlによる動作確認

```bash
# 記事一覧(JSON)
curl -s -H "Accept: application/json" http://localhost:3000/articles

# 記事作成
curl -s -X POST http://localhost:3000/articles \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"article":{"title":"Hello Rails","content":"これはテスト記事です。動作確認用。","user_id":1}}'

# 記事詳細
curl -s -H "Accept: application/json" http://localhost:3000/articles/1

# 記事更新
curl -s -X PATCH http://localhost:3000/articles/1 \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"article":{"title":"Updated Title"}}'

# 記事削除
curl -s -X DELETE -H "Accept: application/json" http://localhost:3000/articles/1

# コメント一覧
curl -s -H "Accept: application/json" http://localhost:3000/articles/1/comments

# コメント作成
curl -s -X POST http://localhost:3000/articles/1/comments \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"comment":{"body":"テストコメントです。","user_id":1}}'
```

`skip_forgery_protection`を開発環境の動作確認用に設定しています。本番環境では`protect_from_forgery with: :null_session`に置き換えてください。

## 含まれるモデル

| モデル | 説明 |
|--------|------|
| User | ユーザー。記事とコメントの作成者 |
| Article | 記事。公開/下書き管理、スコープ、検索メソッドを実装 |
| Comment | コメント。ユーザーと記事に紐づく |
| Group | グループ。Membershipを介したユーザーとの多対多関連 |
| Membership | 中間テーブル。enum :roleでメンバー/モデレーター/管理者を管理 |

## Ruby / Railsバージョン

- Ruby 3.4.8
- Rails 8.1.3
- SQLite3
