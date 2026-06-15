# 第4章: ビューの構造化とフロントエンド統合

Rails実践チュートリアル第4章のサンプルアプリケーションです。第2章(ActiveRecord)・第3章(ルーティングとコントローラ)の内容を統合し、ビューとフロントエンドの実装を追加しています。

## この章で実装した内容

- `resources :articles` と `comments` のネストしたルーティング
- `ArticlesController` の7アクション（index/show/new/edit/create/update/destroy）と `respond_to` による HTML/Turbo Stream 切り替え
- `CommentsController` のネストした `create` アクション
- `application.html.erb` レイアウト（ヘッダー・フッター・フラッシュメッセージのパーシャル分割）
- `_article.html.erb` パーシャルによるコレクション描画
- `form_with` を使った記事投稿フォームとバリデーションエラー表示
- `ApplicationHelper` の `error_messages_for`、`field_error_class`、`field_error_message`
- Turbo Frame による記事一覧の部分更新
- Turbo Stream テンプレート（create/destroy）
- Stimulus コントローラ: `dropdown_controller.js`、`autosubmit_controller.js`、`counter_controller.js`
- Importmap によるバンドラー不要のJavaScript配信

## セットアップ

```bash
bundle install
bin/rails db:create db:migrate db:seed
```

## 起動

```bash
bin/rails server
```

`http://localhost:3000/articles` を開くと記事一覧が表示されます。

## 動作確認のポイント

- 記事の作成・編集・削除が一通り動作する
- バリデーションエラー（タイトル空欄など）がフィールド単位で表示される
- ブラウザの開発者ツールNetworkタブでTurbo DriveのFetchリクエストを確認できる
- 検索フォームに入力すると500ms後に自動送信される（autosubmit Stimulusコントローラ）

## ファイル構成

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── articles_controller.rb
│   └── comments_controller.rb
├── helpers/
│   └── application_helper.rb
├── javascript/controllers/
│   ├── application.js
│   ├── index.js
│   ├── autosubmit_controller.js
│   ├── counter_controller.js
│   └── dropdown_controller.js
├── models/
│   ├── article.rb
│   ├── comment.rb
│   └── user.rb
└── views/
    ├── articles/
    │   ├── _article.html.erb
    │   ├── _form.html.erb
    │   ├── create.turbo_stream.erb
    │   ├── destroy.turbo_stream.erb
    │   ├── edit.html.erb
    │   ├── index.html.erb
    │   ├── new.html.erb
    │   └── show.html.erb
    ├── comments/
    │   ├── _form.html.erb
    │   └── create.turbo_stream.erb
    ├── layouts/
    │   └── application.html.erb
    └── shared/
        ├── _flash.html.erb
        ├── _footer.html.erb
        └── _header.html.erb
config/
├── importmap.rb
└── routes.rb
```

## Ruby / Rails バージョン

- Ruby 3.4.8
- Rails 8.1.3
- SQLite3
