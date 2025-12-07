# 第3章：RESTfulなルーティングとコントローラ設計

## 3.1 resourcesルーティングが表現するCRUD操作

### なぜRESTの原則に従うと設計が明確になるのか

RESTは「Representational State Transfer」の略で、Webアプリケーションの設計における標準的なアーキテクチャスタイルです。RESTの原則に従うことで、APIの設計が直感的で予測可能になります。

Railsの`resources`ルーティングは、RESTの原則を実装する最も簡単な方法です。

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :articles
end
```

この1行で、7つの標準的なルートが自動生成されます。

```text
GET    /articles          articles#index   記事の一覧
GET    /articles/new      articles#new     新規作成フォーム
POST   /articles          articles#create  記事の作成
GET    /articles/:id      articles#show    記事の詳細
GET    /articles/:id/edit articles#edit    編集フォーム
PATCH  /articles/:id      articles#update  記事の更新
DELETE /articles/:id      articles#destroy 記事の削除
```

このルーティングは、HTTPメソッド（GET、POST、PATCH、DELETE）とURLの組み合わせで、操作の意図を表現しています。

RESTの利点は、URLを見るだけでどのような操作が行われるかが明確になることです。`GET /articles`は記事の一覧取得、`POST /articles`は新規作成、`DELETE /articles/:id`は削除、という具合に、HTTPメソッドとURLの組み合わせが操作の意味を明示します。

また、RESTful設計により、コントローラのアクションに一貫性が生まれます。どのリソースでも同じパターンが繰り返されるため、新しい開発者がコードベースを理解しやすくなります。

### 標準的な7つのアクション以外が必要になる判断基準

RESTの7つのアクションで表現できない操作が必要になる場合があります。その場合、カスタムアクションを追加できます。

```ruby
resources :articles do
  member do
    post :publish    # POST /articles/:id/publish
    post :unpublish  # POST /articles/:id/unpublish
  end
  
  collection do
    get :archived    # GET /articles/archived
  end
end
```

`member`は特定のリソースに対する操作を定義します。`:id`パラメータが必要です。`publish`アクションは、特定の記事を公開する操作を表現します。

`collection`はリソース全体に対する操作を定義します。`:id`パラメータは不要です。`archived`アクションは、アーカイブされた記事の一覧を取得します。

カスタムアクションを追加すべきかの判断基準を以下に示します。

新しいリソースとして切り出せるなら、そうすべきです。例えば、記事の公開を`Publication`という独立したリソースとして扱うことができます。

```ruby
resources :articles do
  resource :publication, only: [:create, :destroy]
end
```

この設計では、`POST /articles/:id/publication`で記事を公開し、`DELETE /articles/:id/publication`で非公開にします。RESTの原則に沿った設計です。

カスタムアクションは最小限に留めるべきです。多くのカスタムアクションが必要な場合、リソースの分割を検討すべきサインです。

### ネストしたリソースを適切に表現する方法

リソース間の関係性を表現するために、ルーティングをネストできます。

```ruby
resources :articles do
  resources :comments
end
```

これにより、以下のようなルートが生成されます。

```text
GET    /articles/:article_id/comments          comments#index
POST   /articles/:article_id/comments          comments#create
GET    /articles/:article_id/comments/:id      comments#show
PATCH  /articles/:article_id/comments/:id      comments#update
DELETE /articles/:article_id/comments/:id      comments#destroy
```

URLが`/articles/:article_id/comments`となることで、「この記事に属するコメント」という関係性が明確になります。

ただし、ネストは1段階に留めるべきです。深いネストはURLを複雑にし、保守性を下げます。

```ruby
# 悪い例：ネストが深すぎる
resources :users do
  resources :articles do
    resources :comments do
      resources :likes
    end
  end
end

# 良い例：シャローネスティング
resources :articles do
  resources :comments, only: [:index, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

`shallow`オプションを使用すると、この設計を簡潔に記述できます。

```ruby
resources :articles do
  resources :comments, shallow: true
end
```

これにより、`index`と`create`は記事配下にネストされ、それ以外のアクションは独立したルートになります。

```text
GET    /articles/:article_id/comments     comments#index
POST   /articles/:article_id/comments     comments#create
GET    /comments/:id                      comments#show
PATCH  /comments/:id                      comments#update
DELETE /comments/:id                      comments#destroy
```

この設計により、コメントの一覧取得と作成は記事のコンテキストで行い、個別のコメント操作はコメントIDだけで完結します。

## 3.2 Strong Parametersによる入力制御

### パラメータの許可リストが必要な理由

ユーザーからの入力を直接モデルに渡すことは、セキュリティリスクです。攻撃者が意図しないパラメータを送信し、データを改ざんする可能性があります。

例えば、以下のようなコントローラがあるとします。

```ruby
# 危険なコード
def create
  @user = User.new(params[:user])
  @user.save
end
```

このコードでは、リクエストに含まれるすべてのパラメータがUserモデルに渡されます。攻撃者が`admin=true`というパラメータを送信すると、一般ユーザーが管理者権限を取得できてしまいます。

Strong Parametersは、明示的に許可したパラメータのみを受け取る仕組みです。

```ruby
def create
  @user = User.new(user_params)
  @user.save
end

private

def user_params
  params.require(:user).permit(:name, :email, :password)
end
```

`require`は指定されたキーが存在することを保証し、`permit`は許可するパラメータを明示的に指定します。このコードでは、`name`、`email`、`password`のみが許可され、それ以外のパラメータは無視されます。

### ネストした属性を安全に受け取る実装

関連するモデルを同時に作成・更新する場合、ネストしたパラメータを許可する必要があります。

```ruby
class ArticlesController < ApplicationController
  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  private

  def article_params
    params.require(:article).permit(
      :title,
      :content,
      :published,
      tag_ids: [],
      images_attributes: [:id, :url, :caption, :_destroy]
    )
  end
end
```

`tag_ids: []`は、配列パラメータを許可します。複数のタグを選択できるチェックボックスなどで使用します。

`images_attributes`は、ネストした属性を許可します。`accepts_nested_attributes_for`を使用している場合に必要です。

```ruby
class Article < ApplicationRecord
  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true
end
```

`_destroy`パラメータを許可することで、関連レコードの削除を可能にします。

ハッシュのパラメータを許可する場合は、以下のように記述します。

```ruby
def article_params
  params.require(:article).permit(
    :title,
    :content,
    metadata: [:author, :source, :publish_date]
  )
end
```

ただし、任意のキーを持つハッシュを許可する場合は注意が必要です。

```ruby
# すべてのキーを許可する場合
def article_params
  params.require(:article).permit(:title, :content, metadata: {})
end
```

空のハッシュ`{}`を指定すると、`metadata`内のすべてのキーが許可されます。これは便利ですが、予期しないデータが保存される可能性があるため、慎重に使用すべきです。

### permitとrequireの使い分けが重要な場面

`require`はパラメータの存在を強制し、`permit`は許可するパラメータを指定します。両者の使い分けを理解することが重要です。

`require`は、必須のキーが存在しない場合に例外を発生させます。

```ruby
params.require(:article)  # :article キーが存在しない場合、例外が発生
```

これにより、不正なリクエストを早期に検出できます。通常、モデル名に対応するキーに対して使用します。

`permit`は、許可するパラメータを指定します。許可されていないパラメータは自動的に除外されます。

```ruby
params.require(:article).permit(:title, :content)
```

複数のパラメータセットを扱う場合の例を示します。

```ruby
class ArticlesController < ApplicationController
  def update
    @article = Article.find(params[:id])
    
    # 管理者のみが公開ステータスを変更できる
    if current_user.admin?
      @article.update(admin_article_params)
    else
      @article.update(article_params)
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :content)
  end

  def admin_article_params
    params.require(:article).permit(:title, :content, :published, :featured)
  end
end
```

この設計により、通常のユーザーと管理者で異なるパラメータセットを使用できます。

条件付きでパラメータを許可する場合もあります。

```ruby
def article_params
  permitted = [:title, :content]
  permitted << :published if current_user.can_publish?
  params.require(:article).permit(*permitted)
end
```

## 3.3 例外処理とエラーレスポンスの統一

### rescue_fromで例外をハンドリングする利点

コントローラで発生する例外を適切に処理することで、ユーザーに分かりやすいエラーメッセージを表示できます。

`rescue_from`は、特定の例外をキャッチして処理するRailsの機能です。

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found
    render file: "#{Rails.root}/public/404.html", 
           status: :not_found, 
           layout: false
  end

  def parameter_missing(exception)
    render json: { error: exception.message }, 
           status: :bad_request
  end
end
```

この設定により、`ActiveRecord::RecordNotFound`が発生した場合、404エラーページが表示されます。`find`メソッドでレコードが見つからない場合に自動的に処理されます。

個別のコントローラでも例外処理を追加できます。

```ruby
class ArticlesController < ApplicationController
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "この操作を実行する権限がありません"
    redirect_to root_path
  end
end
```

`rescue_from`を使用する利点は、例外処理を一箇所に集約できることです。各アクションでbegin-rescueを書く必要がなくなり、コードの重複が減ります。

### ステータスコードを適切に返す重要性

HTTPステータスコードは、リクエストの結果をクライアントに伝える標準的な方法です。適切なステータスコードを返すことで、APIの使いやすさが向上します。

主要なステータスコードを以下に示します。

200 OK は、リクエストが成功したことを示します。GETリクエストでデータを取得した場合に使用します。

201 Created は、リソースが正常に作成されたことを示します。POSTリクエストで新規リソースを作成した場合に使用します。

204 No Content は、リクエストは成功したがレスポンスボディがないことを示します。DELETEリクエストで使用されることが多いです。

400 Bad Request は、リクエストの形式が不正であることを示します。バリデーションエラーや不正なパラメータの場合に使用します。

401 Unauthorized は、認証が必要であることを示します。ログインしていないユーザーがアクセスした場合に使用します。

403 Forbidden は、認証はされているが権限がないことを示します。管理者専用ページに一般ユーザーがアクセスした場合に使用します。

404 Not Found は、リソースが見つからないことを示します。

422 Unprocessable Entity は、リクエストは正しいがバリデーションエラーがあることを示します。

500 Internal Server Error は、サーバー内部でエラーが発生したことを示します。

Railsでステータスコードを指定する方法を示します。

```ruby
class ArticlesController < ApplicationController
  def create
    @article = Article.new(article_params)
    
    if @article.save
      render json: @article, status: :created
    else
      render json: { errors: @article.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    head :no_content
  end
end
```

シンボルでステータスコードを指定できます。Railsは`:created`を201に、`:unprocessable_entity`を422に変換します。

### JSON APIとしてエラーを表現する設計

JSON APIとして設計する場合、エラーレスポンスの形式を統一することが重要です。

標準的なエラーレスポンスの形式を示します。

```ruby
{
  "errors": [
    {
      "status": "422",
      "code": "validation_failed",
      "title": "Validation Failed",
      "detail": "Title can't be blank",
      "source": {
        "pointer": "/data/attributes/title"
      }
    }
  ]
}
```

この形式は、JSON:API仕様に準拠しています。エラーの詳細情報を構造化して提供することで、クライアント側での処理が容易になります。

Railsでこの形式を実装する例を示します。

```ruby
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  private

  def record_not_found
    render json: {
      errors: [{
        status: '404',
        title: 'Record Not Found',
        detail: 'The requested resource was not found'
      }]
    }, status: :not_found
  end

  def record_invalid(exception)
    render json: {
      errors: exception.record.errors.map do |error|
        {
          status: '422',
          code: 'validation_failed',
          title: 'Validation Failed',
          detail: error.full_message,
          source: { pointer: "/data/attributes/#{error.attribute}" }
        }
      end
    }, status: :unprocessable_entity
  end
end
```

この実装により、すべてのバリデーションエラーが統一された形式で返されます。

コントローラでの使用例を示します。

```ruby
class ArticlesController < ApplicationController
  def create
    @article = Article.new(article_params)
    @article.save!
    render json: @article, status: :created
  rescue ActiveRecord::RecordInvalid => e
    # ApplicationControllerのrescue_fromが自動的に処理
    raise
  end
end
```

エラーレスポンスの設計原則を以下に示します。

一貫性を保つことが最も重要です。すべてのエンドポイントで同じエラー形式を使用します。

詳細な情報を提供することで、クライアント側でのデバッグが容易になります。どのフィールドでエラーが発生したかを明確にします。

適切なHTTPステータスコードを使用することで、エラーの種類を明確にします。

機密情報を含めないように注意します。スタックトレースやデータベースの詳細は本番環境では表示しません。

## まとめ

この章では、RESTfulなルーティングとコントローラ設計について学びました。

`resources`ルーティングは、RESTの原則に従った標準的な7つのアクションを提供します。この規約により、APIの設計が直感的で予測可能になります。カスタムアクションが必要な場合は、新しいリソースとして切り出せないか検討すべきです。

Strong Parametersは、セキュリティの要です。明示的に許可したパラメータのみを受け取ることで、マスアサインメント脆弱性を防ぎます。ネストした属性や配列パラメータも適切に処理できます。

例外処理とエラーレスポンスの統一により、ユーザーフレンドリーなAPIを構築できます。`rescue_from`で例外を一箇所で処理し、適切なHTTPステータスコードを返すことで、クライアント側での処理が容易になります。

次章では、ビューの構造化とフロントエンド統合について学びます。パーシャルとレイアウトによる再利用設計、FormヘルパーとStimulusによるインタラクション、アセットパイプラインについて習得します。
