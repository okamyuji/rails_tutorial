# 第3章：RESTfulなルーティングとコントローラ設計 - 実装

この章では、RESTfulなルーティングとコントローラの設計を実際に実装します。

## 前提条件

- Ruby 3.2以上
- Rails 8.0以上
- 第2章で学んだActiveRecordの知識

## 実装の進め方

### 1. Railsプロジェクトの作成

```bash
cd rails_tutorial/03_routing_controllers
rails new api_app --api --database=postgresql --skip-test
cd api_app
```

`--api`オプションを使用して、API専用のRailsアプリケーションを作成します。

### 2. データベースの作成

```bash
cd api_app
rails db:create
```

### 3. モデルの作成

```bash
# ユーザーモデル
rails generate model User name:string email:string

# 記事モデル
rails generate model Article title:string content:text published:boolean user:references

# コメントモデル
rails generate model Comment content:text user:references article:references

# マイグレーションを実行
rails db:migrate
```

### 4. コントローラの生成

```bash
rails generate controller Api::V1::Articles
rails generate controller Api::V1::Comments
rails generate controller Api::V1::Users
```

API用のコントローラを`Api::V1`名前空間で作成します。バージョニングにより、後方互換性を保ちながらAPIを進化させることができます。

### 5. ルーティングの設定

`config/routes.rb`を編集して、RESTfulなルーティングを設定します。提供されているサンプルファイルを参照してください。

### 5.5 セキュリティチェックの自動化

マスアサインメント脆弱性、CSRF漏れ、安全でないリダイレクトなどは、`brakeman` gemで静的に検出できます。レビュー時の見落としを防ぐため、CIに組み込みます。

```bash
bundle add brakeman --group development,test
bundle exec brakeman --no-pager --exit-on-warn
```

CIへの統合は[第7章のCI設定](../07_deployment_operations/github_actions/ci.yml)に含まれています。pre-commitで同じチェックをローカル実行することもできます（[`pre-commit-config.yaml`](../07_deployment_operations/github_actions/pre-commit-config.yaml)）。

### 6. デモスクリプトの実行

このディレクトリには、ルーティングとコントローラの機能を確認するためのスクリプトが用意されています。

#### routes_demo.rb - ルーティングの確認

```bash
cd api_app
rails runner ../routes_demo.rb
```

このスクリプトは、定義されているルートを一覧表示し、RESTfulなルーティングの構造を確認できます。

#### strong_parameters_demo.rb - Strong Parametersのデモ

```bash
cd api_app
rails runner ../strong_parameters_demo.rb
```

このスクリプトは、Strong Parametersによるパラメータフィルタリングの動作を確認します。

#### error_handling_demo.rb - エラーハンドリングのデモ

```bash
cd api_app
rails runner ../error_handling_demo.rb
```

このスクリプトは、様々なエラーケースとそのハンドリング方法を実演します。

### 7. APIのテスト（curl）

サーバを起動して、curlコマンドでAPIをテストできます。

```bash
# サーバを起動
rails server

# 別のターミナルで以下を実行

# ユーザーの作成
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"user": {"name": "Alice", "email": "alice@example.com"}}'

# ユーザー一覧の取得
curl http://localhost:3000/api/v1/users

# 特定のユーザーの取得
curl http://localhost:3000/api/v1/users/1

# ユーザーの更新
curl -X PATCH http://localhost:3000/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{"user": {"name": "Alice Updated"}}'

# ユーザーの削除
curl -X DELETE http://localhost:3000/api/v1/users/1
```

### 8. Railsコンソールで試す

```bash
cd api_app
rails console
```

コンソール内で以下のようなコードを実行できます。

```ruby
# ルートの確認
Rails.application.routes.routes.map { |r| r.path.spec.to_s }

# 特定のルートの検索
Rails.application.routes.recognize_path('/api/v1/articles', method: :get)

# URLヘルパーの使用
app.api_v1_articles_path
app.api_v1_article_path(1)

# 終了
exit
```

## 提供されているファイル

### ルーティング設定

- `routes/routes_basic.rb` - 基本的なresourcesルーティング
- `routes/routes_nested.rb` - ネストしたルーティング
- `routes/routes_custom.rb` - カスタムアクションの追加

### コントローラ

- `controllers/api/v1/articles_controller.rb` - 記事APIコントローラ
- `controllers/api/v1/comments_controller.rb` - コメントAPIコントローラ
- `controllers/api/v1/users_controller.rb` - ユーザーAPIコントローラ
- `controllers/concerns/error_handler.rb` - エラーハンドリングの共通処理

### デモスクリプト

- `routes_demo.rb` - ルーティングの確認
- `strong_parameters_demo.rb` - Strong Parametersのデモ
- `error_handling_demo.rb` - エラーハンドリングのデモ
- `api_test.sh` - curlを使用したAPIテストスクリプト

## まとめ

この実装を通じて、以下の点を確認しました。

- RESTfulなルーティングの設計
- resourcesとネストしたルーティング
- カスタムアクションの追加
- Strong Parametersによる入力制御
- 例外処理とエラーレスポンス
- APIバージョニング

次章では、ビューの構造化とフロントエンド統合に進みます。
