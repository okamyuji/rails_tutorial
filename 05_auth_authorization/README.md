# 第5章：認証と認可の実装

この章では、Deviseによるユーザー認証とPunditによる権限管理を実装します。

## 前提条件

- Ruby 3.2以上
- Rails 7.2以上
- PostgreSQL

## ディレクトリ構造

```text
05_auth_authorization/
├── config/                      # 設定ファイル
│   ├── devise.rb               # Devise設定
│   ├── session_store.rb        # セッション設定
│   └── omniauth.rb             # OmniAuth設定
├── controllers/                 # コントローラ
│   ├── application_controller.rb # 認証・認可の基盤
│   └── users/
│       ├── omniauth_callbacks_controller.rb
│       ├── registrations_controller.rb
│       └── sessions_controller.rb
├── models/                      # モデル
│   ├── user.rb                 # Userモデル（Devise）
│   └── permission.rb           # 権限モデル
├── policies/                    # Punditポリシー
│   ├── application_policy.rb   # 基底ポリシー
│   ├── article_policy.rb       # 記事ポリシー
│   └── comment_policy.rb       # コメントポリシー
├── views/                       # ビュー
│   └── devise/
│       ├── sessions/
│       │   └── new.html.erb
│       ├── registrations/
│       │   ├── new.html.erb
│       │   └── edit.html.erb
│       ├── passwords/
│       │   ├── new.html.erb
│       │   └── edit.html.erb
│       ├── confirmations/
│       │   └── new.html.erb
│       └── shared/
│           └── _links.html.erb
├── auth_demo.rb                # 認証デモ
├── devise_demo.rb              # Deviseデモ
├── omniauth_demo.rb            # OmniAuthデモ
├── pundit_demo.rb              # Punditデモ
├── session_demo.rb             # セッションデモ
├── README.md                   # このファイル
└── seed_data.rb                # サンプルデータ生成
```

## デモスクリプトの実行

```bash
# 認証機能の概要デモ
rails runner auth_demo.rb

# Deviseの詳細デモ
rails runner devise_demo.rb

# OmniAuthの詳細デモ
rails runner omniauth_demo.rb

# Punditの詳細デモ
rails runner pundit_demo.rb

# セッション管理のデモ
rails runner session_demo.rb

# サンプルデータの生成
rails runner seed_data.rb
```

## 主な実装内容

### 1. Deviseによるユーザー認証

#### インストールと設定

```ruby
# Gemfile
gem 'devise'
```

```bash
bundle install
rails generate devise:install
rails generate devise User
rails db:migrate
```

#### Userモデル

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable
end
```

#### 認証の要求

```ruby
class ArticlesController < ApplicationController
  before_action :authenticate_user!
end
```

### 2. OmniAuthによる外部認証

```ruby
# Gemfile
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
```

```ruby
# config/initializers/devise.rb
config.omniauth :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
```

### 3. Punditによる権限管理

```ruby
# Gemfile
gem 'pundit'
```

#### ポリシークラス

```ruby
class ArticlePolicy < ApplicationPolicy
  def update?
    user.present? && (record.user == user || user.admin?)
  end
  
  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(published: true)
      end
    end
  end
end
```

#### コントローラでの使用

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
    authorize @article
  end
end
```

### 4. セッションとCookie管理

```ruby
# セッション設定
Rails.application.config.session_store :cookie_store,
  key: '_myapp_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax
```

## ベストプラクティス

### 認証

1. **パスワードポリシー** - 強力なパスワードを要求
2. **セッション管理** - 適切なタイムアウト設定
3. **CSRF対策** - トークン検証を有効化
4. **セキュアCookie** - HTTPSでのみ送信

### 認可

1. **最小権限の原則** - 必要最小限の権限のみ付与
2. **ポリシーの集約** - ロジックをポリシークラスに集約
3. **テストの充実** - 権限仕様をテストで保証
4. **監査ログ** - 重要な操作を記録

## 次のステップ

1. サーバーを起動: `rails server`
2. ユーザー登録: `http://localhost:3000/users/sign_up`
3. ログイン: `http://localhost:3000/users/sign_in`
4. 権限の動作を確認

次章では、テストとデバッグについて学びます。
