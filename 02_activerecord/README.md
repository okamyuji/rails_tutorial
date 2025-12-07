# 第2章：ActiveRecordによるデータモデリングの実践 - 実装

この章では、ActiveRecordの機能を実際に使用してデータモデリングを行います。

## 前提条件

- Ruby 3.2以上
- Rails 7.2以上
- PostgreSQLまたはSQLite3

## 実装の進め方

### 1. Railsプロジェクトの作成

```bash
cd rails_tutorial/02_activerecord
rails new blog_app --database=postgresql --skip-test
cd blog_app
```

PostgreSQLを使用しない場合は、`--database=sqlite3`を指定してください。

### 2. データベースの作成

```bash
cd blog_app
rails db:create
```

### 3. モデルとマイグレーションの作成

#### Userモデル

```bash
rails generate model User name:string email:string:uniq age:integer
```

このコマンドは以下のファイルを生成します。

- `app/models/user.rb` - Userモデル
- `db/migrate/YYYYMMDDHHMMSS_create_users.rb` - マイグレーションファイル

生成されたマイグレーションファイルを確認し、必要に応じて修正します。

```bash
cat db/migrate/*_create_users.rb
```

#### Articleモデル

```bash
rails generate model Article title:string content:text published:boolean published_at:datetime user:references
```

#### Commentモデル

```bash
rails generate model Comment content:text user:references article:references
```

#### Groupモデルと中間テーブル

```bash
rails generate model Group name:string description:text
rails generate model Membership user:references group:references role:integer
```

### 4. マイグレーションの実行

```bash
rails db:migrate
```

スキーマの状態を確認します。

```bash
cat db/schema.rb
```

### 5. モデルの関連付けとバリデーションを定義

生成されたモデルファイルを編集して、関連付けとバリデーションを追加します。

モデルファイルは`app/models/`ディレクトリにあります。各モデルファイルに適切な関連付けとバリデーションを定義してください。詳細は、提供されているサンプルファイルを参照してください。

### 6. デモスクリプトの実行

このディレクトリには、ActiveRecordの機能を確認するためのスクリプトが用意されています。

#### seed_data.rb - サンプルデータの投入

```bash
cd blog_app
rails runner ../seed_data.rb
```

このスクリプトは、ユーザー、記事、コメント、グループのサンプルデータを作成します。

#### n_plus_one_demo.rb - N+1問題のデモ

```bash
cd blog_app
rails runner ../n_plus_one_demo.rb
```

このスクリプトは、N+1問題が発生するケースと、`includes`を使用して解決するケースを比較します。実行されたSQLクエリの数を確認できます。

#### transaction_demo.rb - トランザクションのデモ

```bash
cd blog_app
rails runner ../transaction_demo.rb
```

このスクリプトは、トランザクションの動作を確認します。正常系とエラー時のロールバックを実演します。

#### validation_demo.rb - バリデーションのデモ

```bash
cd blog_app
rails runner ../validation_demo.rb
```

このスクリプトは、各種バリデーションの動作を確認します。エラーメッセージの取得方法も示します。

#### query_optimization_demo.rb - クエリ最適化のデモ

```bash
cd blog_app
rails runner ../query_optimization_demo.rb
```

このスクリプトは、スコープ、joins、includes、eager_loadの使い分けを示します。

### 7. Railsコンソールで試す

Railsコンソールを起動して、対話的にActiveRecordの機能を試すことができます。

```bash
cd blog_app
rails console
```

コンソール内で以下のようなコードを実行できます。

```ruby
# ユーザーの作成
user = User.create(name: "Alice", email: "alice@example.com", age: 28)

# 記事の作成
article = user.articles.create(title: "First Post", content: "Hello, World!")

# 関連の取得
user.articles
article.user

# クエリの実行
User.where("age > ?", 25)
Article.published.recent.limit(10)

# N+1問題の確認
users = User.limit(10)
users.each { |u| puts u.articles.count }  # N+1問題が発生

users = User.includes(:articles).limit(10)
users.each { |u| puts u.articles.count }  # 最適化済み

# 終了
exit
```

### 8. マイグレーションの確認

マイグレーションの状態を確認できます。

```bash
# 実行済みマイグレーションの一覧
rails db:migrate:status

# ロールバック（最後のマイグレーションを取り消し）
rails db:rollback

# 再度実行
rails db:migrate

# 特定のバージョンまでロールバック
rails db:migrate VERSION=20240101120000
```

### 9. データベースのリセット

開発中にデータベースをクリーンな状態に戻したい場合は、以下のコマンドを使用します。

```bash
# データベースを削除、再作成、マイグレーション実行
rails db:reset

# さらにシードデータも投入
rails db:seed
```

## 提供されているファイル

### モデルファイル

- `models/user.rb` - Userモデルの完全な実装例
- `models/article.rb` - Articleモデルの完全な実装例
- `models/comment.rb` - Commentモデルの完全な実装例
- `models/group.rb` - Groupモデルの完全な実装例
- `models/membership.rb` - Membershipモデルの完全な実装例

### マイグレーションファイル

- `migrations/add_indexes_example.rb` - インデックス追加の例
- `migrations/add_foreign_keys_example.rb` - 外部キー制約追加の例

### デモスクリプト

- `seed_data.rb` - サンプルデータ投入
- `n_plus_one_demo.rb` - N+1問題のデモ
- `transaction_demo.rb` - トランザクションのデモ
- `validation_demo.rb` - バリデーションのデモ
- `query_optimization_demo.rb` - クエリ最適化のデモ

## まとめ

この実装を通じて、以下の点を確認しました。

- マイグレーションによるスキーマ管理
- モデルの関連付け（belongs_to, has_many, has_many through）
- N+1問題の発生と解決
- バリデーションの実装
- トランザクションによるデータ整合性保証
- スコープとクエリメソッドの活用

次章では、RESTfulなルーティングとコントローラ設計に進みます。
