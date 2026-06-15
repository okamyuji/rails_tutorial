# 第2章：ActiveRecordによるデータモデリングの実践

Rails実践チュートリアル第2章のサンプルアプリです。ActiveRecordを使用したデータモデリングの基礎を学びます。

## セットアップ

```bash
bundle install
bin/rails db:create db:migrate
```

## 含まれるモデル

| モデル | 説明 |
|--------|------|
| User | ユーザー。記事・コメント・グループとの関連を持つ |
| Article | 記事。公開/下書き管理、スコープ、検索メソッドを実装 |
| Comment | コメント。ユーザーと記事に紐づく |
| Group | グループ。Membershipを介したユーザーとの多対多関連 |
| Membership | 中間テーブル。enum :role でメンバー/モデレーター/管理者を管理 |

## 動作確認

```bash
bin/rails console
```

```ruby
user = User.create!(name: "テスト太郎", email: "test@example.com")
article = user.articles.create!(title: "はじめての記事", content: "ActiveRecordの基本を学びます。")
article.publish!
Article.published.recent.count
Article.search("はじめて")
```

## 主な学習ポイント

- マイグレーションによるスキーマ管理
- belongs_to / has_many / has_many through の関連付け
- バリデーションとデータベース制約の二重防御
- scope とクラスメソッドによるクエリ設計
- N+1問題と includes による解決
- strong_migrations による危険なマイグレーションの検出

## Ruby / Rails バージョン

- Ruby 3.4.8
- Rails 8.1.3
- SQLite3
