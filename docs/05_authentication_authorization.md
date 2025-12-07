# 第5章：認証と認可の実装

## 5.1 Deviseによるユーザー認証

### Deviseが提供する機能とカスタマイズ

Deviseは、Railsにおける認証の標準的なソリューションです。ユーザー登録、ログイン、パスワードリセットなどの機能を提供します。

Gemfileに追加してインストールします。

```ruby
gem 'devise'
```

```bash
bundle install
rails generate devise:install
rails generate devise User
rails db:migrate
```

Deviseは、10のモジュールを提供します。必要なものだけを有効化できます。

Database Authenticatableは、メールアドレスとパスワードによる認証を提供します。これは必須のモジュールです。

Registerableは、ユーザー登録機能を提供します。新規ユーザーがアカウントを作成できます。

Recoverableは、パスワードリセット機能を提供します。ユーザーがパスワードを忘れた場合に再設定できます。

Rememberableは、「ログイン状態を保持する」機能を提供します。Cookieを使用してセッションを永続化します。

Trackableは、ログイン回数、最終ログイン日時などを記録します。

Validatableは、メールアドレスとパスワードのバリデーションを提供します。

Confirmableは、メールアドレスの確認機能を提供します。登録後に確認メールが送信されます。

Lockableは、一定回数ログインに失敗するとアカウントをロックします。ブルートフォース攻撃を防ぎます。

Timeoutableは、一定時間操作がない場合に自動的にログアウトします。

Omniauthableは、外部認証プロバイダ（Google、Facebook）との連携を提供します。

モデルで必要なモジュールを指定します。

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable
end
```

コントローラで認証を要求します。

```ruby
class ArticlesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @articles = Article.all
  end
end
```

ビューでログイン状態を確認します。

```erb
<% if user_signed_in? %>
  <p>Welcome, <%= current_user.email %>!</p>
  <%= button_to "Sign out", destroy_user_session_path, method: :delete %>
<% else %>
  <%= link_to "Sign in", new_user_session_path %>
  <%= link_to "Sign up", new_user_registration_path %>
<% end %>
```

Deviseのビューをカスタマイズするには、ビューファイルを生成します。

```bash
rails generate devise:views
```

これにより、`app/views/devise`配下にビューファイルが作成されます。デザインを自由に変更できます。

コントローラもカスタマイズできます。

```bash
rails generate devise:controllers users
```

ルーティングを更新して、カスタムコントローラを使用します。

```ruby
devise_for :users, controllers: {
  sessions: 'users/sessions',
  registrations: 'users/registrations'
}
```

Strong Parametersを追加する場合は、コントローラで設定します。

```ruby
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  
  protected
  
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :age])
  end
end
```

### OmniAuthで外部認証を統合する方法

OmniAuthを使用すると、Google、Facebook、GitHubなどの外部サービスで認証できます。

OmniAuth gemをインストールします。

```ruby
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
```

Deviseの設定ファイルでOmniAuthを有効化します。

```ruby
# config/initializers/devise.rb
config.omniauth :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
```

Userモデルで`omniauthable`モジュールを有効化します。

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
end
```

OmniAuthのコールバックを処理するコントローラを作成します。

```ruby
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
```

Userモデルにクラスメソッドを追加します。

```ruby
class User < ApplicationRecord
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
    end
  end
end
```

ビューにログインボタンを追加します。

```erb
<%= button_to "Sign in with Google", user_google_oauth2_omniauth_authorize_path, 
              method: :post, data: { turbo: false } %>
```

### セッションとCookieの適切な管理

セッションは、ユーザーの状態をリクエスト間で保持する仕組みです。Railsは、デフォルトでCookieベースのセッションを使用します。

セッションストアを設定します。

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store, 
  key: '_myapp_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax
```

`secure: true`は、HTTPS接続でのみCookieを送信します。本番環境では必須です。

`httponly: true`は、JavaScriptからのCookie アクセスを防ぎます。XSS攻撃を軽減します。

`same_site: :lax`は、クロスサイトリクエストでのCookie送信を制限します。CSRF攻撃を防ぎます。

セッションの有効期限を設定する場合は、Redisなどの外部ストアを使用します。

```ruby
# Gemfile
gem 'redis-rails'

# config/initializers/session_store.rb
Rails.application.config.session_store :redis_store,
  servers: ENV['REDIS_URL'],
  expire_after: 1.week,
  key: '_myapp_session'
```

コントローラでセッションを操作します。

```ruby
# セッションに値を保存
session[:user_preference] = 'dark_mode'

# セッションから値を取得
user_preference = session[:user_preference]

# セッションをクリア
reset_session
```

Cookieも直接操作できます。

```ruby
# Cookieを設定
cookies[:theme] = {
  value: 'dark',
  expires: 1.year.from_now,
  secure: true,
  httponly: false
}

# Cookieを取得
theme = cookies[:theme]

# Cookieを削除
cookies.delete(:theme)
```

暗号化されたCookieを使用することもできます。

```ruby
# 暗号化されたCookieを設定
cookies.encrypted[:user_id] = current_user.id

# 暗号化されたCookieを取得
user_id = cookies.encrypted[:user_id]
```

署名付きCookieは、改ざんを検出できます。

```ruby
cookies.signed[:user_id] = current_user.id
user_id = cookies.signed[:user_id]
```

## 5.2 Punditによる権限管理

### ポリシークラスで権限ロジックを整理する

Punditは、権限管理を宣言的に記述するgemです。ポリシークラスに権限ロジックを集約します。

```ruby
# Gemfile
gem 'pundit'
```

ApplicationControllerにPunditを組み込みます。

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  private
  
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
```

ポリシークラスを作成します。

```ruby
# app/policies/article_policy.rb
class ArticlePolicy < ApplicationPolicy
  def index?
    true  # 誰でも一覧を表示できる
  end
  
  def show?
    true  # 誰でも記事を閲覧できる
  end
  
  def create?
    user.present?  # ログインユーザーのみ作成できる
  end
  
  def update?
    user.present? && (record.user == user || user.admin?)
  end
  
  def destroy?
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

コントローラで権限チェックを実行します。

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = policy_scope(Article)
  end
  
  def show
    @article = Article.find(params[:id])
    authorize @article
  end
  
  def create
    @article = Article.new(article_params)
    authorize @article
    
    if @article.save
      redirect_to @article
    else
      render :new
    end
  end
  
  def update
    @article = Article.find(params[:id])
    authorize @article
    
    if @article.update(article_params)
      redirect_to @article
    else
      render :edit
    end
  end
end
```

ビューで権限を確認します。

```erb
<% if policy(@article).update? %>
  <%= link_to 'Edit', edit_article_path(@article) %>
<% end %>

<% if policy(@article).destroy? %>
  <%= button_to 'Delete', @article, method: :delete %>
<% end %>
```

ポリシーに複雑なロジックを追加できます。

```ruby
class ArticlePolicy < ApplicationPolicy
  def publish?
    user.present? && (record.user == user || user.editor? || user.admin?)
  end
  
  def permitted_attributes
    if user.admin?
      [:title, :content, :published, :featured]
    else
      [:title, :content]
    end
  end
end
```

コントローラで許可される属性を使用します。

```ruby
def article_params
  params.require(:article).permit(policy(@article).permitted_attributes)
end
```

### ロールベースとリソースベースの権限設計

権限管理には、ロールベースとリソースベースの2つのアプローチがあります。

ロールベースは、ユーザーに役割（admin、editor、memberなど）を割り当てます。

```ruby
class User < ApplicationRecord
  enum role: { member: 0, editor: 1, admin: 2 }
end
```

ポリシーで役割をチェックします。

```ruby
class ArticlePolicy < ApplicationPolicy
  def update?
    user.admin? || user.editor? || record.user == user
  end
end
```

リソースベースは、個別のリソースに対する権限を管理します。記事の所有者のみが編集できる、などです。

```ruby
def update?
  record.user == user
end
```

両方を組み合わせることもできます。

```ruby
def update?
  user.admin? || record.user == user
end
```

複雑な権限を表現する場合は、独立したテーブルで管理します。

```ruby
class Permission < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true
  
  enum action: { read: 0, write: 1, delete: 2, admin: 3 }
end
```

ポリシーで動的にチェックします。

```ruby
def update?
  Permission.exists?(
    user: user,
    resource: record,
    action: [:write, :admin]
  )
end
```

### ポリシーのテストで権限仕様を保証する

Punditポリシーは、RSpecでテストできます。

```ruby
# spec/policies/article_policy_spec.rb
require 'rails_helper'

RSpec.describe ArticlePolicy do
  subject { described_class.new(user, article) }
  
  let(:article) { create(:article) }
  
  context 'for a guest user' do
    let(:user) { nil }
    
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end
  
  context 'for the article owner' do
    let(:user) { article.user }
    
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end
  
  context 'for an admin user' do
    let(:user) { create(:user, :admin) }
    
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end
  
  context 'for a different user' do
    let(:user) { create(:user) }
    
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end
end
```

Scopeのテストも重要です。

```ruby
RSpec.describe ArticlePolicy::Scope do
  subject { described_class.new(user, Article).resolve }
  
  let!(:published_article) { create(:article, published: true) }
  let!(:draft_article) { create(:article, published: false) }
  
  context 'for an admin user' do
    let(:user) { create(:user, :admin) }
    
    it 'includes all articles' do
      expect(subject).to include(published_article, draft_article)
    end
  end
  
  context 'for a regular user' do
    let(:user) { create(:user) }
    
    it 'includes only published articles' do
      expect(subject).to include(published_article)
      expect(subject).not_to include(draft_article)
    end
  end
end
```

## まとめ

この章では、認証と認可の実装について学びました。

Deviseは、ユーザー認証の標準的なソリューションです。登録、ログイン、パスワードリセットなどの機能を提供し、カスタマイズも容易です。OmniAuthと組み合わせることで、外部サービスによる認証も実装できます。

Punditは、権限管理を宣言的に記述します。ポリシークラスに権限ロジックを集約することで、コードの可読性と保守性が向上します。ロールベースとリソースベースの権限を柔軟に組み合わせることができます。

セッションとCookieの適切な管理は、セキュリティの要です。secure、httponly、same_siteなどのオプションを正しく設定することで、攻撃を防ぎます。

次章では、テストとデバッグについて学びます。RSpecによる自動テスト、デバッグ技法、パフォーマンス計測を習得します。
