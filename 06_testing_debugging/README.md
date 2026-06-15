# 第6章：テストとデバッグ

Rails実践チュートリアル第6章のサンプルアプリケーションです。第2章（ActiveRecord）をベースに、第3〜5章の機能（ルーティング、コントローラ、ビュー、Devise認証、Pundit認可）を統合し、テスト基盤を構築しています。

## セットアップ

```bash
bundle install
bin/rails db:create db:migrate
```

## テストの実行

```bash
bundle exec rspec
```

テスト実行後、`coverage/index.html`でカバレッジレポートを確認できます。

```bash
open coverage/index.html
```

## 構成

### テスト関連gem

| gem | 用途 |
|-----|------|
| rspec-rails | テストフレームワーク |
| factory_bot_rails | テストデータ生成 |
| faker | ダミーデータ生成 |
| shoulda-matchers | ワンライナーマッチャー |
| simplecov | カバレッジ計測（閾値80%） |
| bullet | N+1クエリ検出 |

### デバッグ/パフォーマンス関連gem

| gem | 用途 |
|-----|------|
| rack-mini-profiler | リクエストごとのパフォーマンス可視化 |
| memory_profiler | メモリプロファイリング |
| stackprof | フレームグラフ生成 |

### テストファイル構成

```
spec/
├── factories/
│   ├── articles.rb
│   ├── comments.rb
│   └── users.rb
├── models/
│   ├── article_spec.rb
│   ├── comment_spec.rb
│   └── user_spec.rb
├── policies/
│   └── article_policy_spec.rb
├── requests/
│   ├── articles_spec.rb
│   └── comments_spec.rb
├── rails_helper.rb
└── spec_helper.rb
```

### テスト設定のポイント

- `spec/spec_helper.rb`: SimpleCovで`minimum_coverage 80`を設定し、閾値未達でテスト失敗
- `config/environments/test.rb`: `Bullet.raise = true`でN+1検出時にテスト失敗
- `spec/rails_helper.rb`: Bullet、Devise、FactoryBotの設定を統合

## アプリケーション機能

- ユーザー認証（Devise）
- 記事のCRUD操作
- 記事の公開/下書き管理
- コメント投稿
- 認可制御（Pundit）

## 動作確認

```bash
bin/rails server
```

`http://localhost:3000`にアクセスして記事一覧を確認できます。

## Ruby / Railsバージョン

- Ruby 3.4.8
- Rails 8.1.3
- SQLite3
