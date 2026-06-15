# 第5章：認証と認可の実装

Rails実践チュートリアル第5章のサンプルアプリです。Deviseによるユーザー認証とPunditによる認可を実装しています。

## セットアップ

```bash
bundle install
bin/rails db:create db:migrate
```

## 含まれる機能

| 機能 | gem | 説明 |
|------|-----|------|
| ユーザー認証 | Devise | サインアップ、ログイン、ログアウト、パスワードリセット |
| 外部認証 | OmniAuth (Google OAuth2) | Google アカウントによるログイン（設定のみ） |
| 認可 | Pundit | ポリシークラスによるアクション単位の権限制御 |
| ロール管理 | ActiveRecord enum | member / editor / admin の3段階ロール |

## 動作確認

```bash
bin/rails server
```

以下のURLにアクセスして動作を確認できます。

- `http://localhost:3000/` — トップページ（公開記事一覧）
- `http://localhost:3000/users/sign_up` — サインアップ画面
- `http://localhost:3000/users/sign_in` — ログイン画面
- `http://localhost:3000/articles` — 記事一覧（ログイン不要）
- `http://localhost:3000/articles/new` — 記事作成（要ログイン）

## OmniAuth（Google OAuth2）を有効にする場合

環境変数を設定してからサーバーを起動してください。

```bash
export GOOGLE_CLIENT_ID="your-client-id"
export GOOGLE_CLIENT_SECRET="your-client-secret"
bin/rails server
```

## 主な構成ファイル

| ファイル | 内容 |
|----------|------|
| `app/models/user.rb` | Deviseモジュール、enum :role、from_omniauth |
| `app/policies/article_policy.rb` | 記事の認可ポリシーとスコープ |
| `app/controllers/application_controller.rb` | authenticate_user!、Pundit統合 |
| `app/controllers/articles_controller.rb` | authorize / policy_scope による認可チェック |
| `app/controllers/users/omniauth_callbacks_controller.rb` | OAuthコールバック処理 |
| `config/initializers/devise.rb` | Devise設定、OmniAuth設定 |

## 認可ルール

| アクション | guest | member | 記事所有者 | admin |
|------------|-------|--------|------------|-------|
| index / show | o | o | o | o |
| create | x | o | o | o |
| update | x | x | o | o |
| destroy | x | x | o | o |

スコープ制御: 一般ユーザーには公開記事のみ表示、admin には全記事を表示します。

## Ruby / Rails バージョン

- Ruby 3.4.8
- Rails 8.1.3
- SQLite3
