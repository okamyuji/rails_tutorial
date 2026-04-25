# frozen_string_literal: true

# カスタムアクションを追加したルーティング

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :articles do
        # member: 特定のリソースに対する操作（:idが必要）
        member do
          post :publish # POST /api/v1/articles/:id/publish
          post :unpublish # POST /api/v1/articles/:id/unpublish
        end

        # collection: リソース全体に対する操作（:idは不要）
        collection do
          get :published # GET /api/v1/articles/published
          get :drafts # GET /api/v1/articles/drafts
        end

        # コメントをネスト
        resources :comments, only: %i[index create]
      end

      resources :comments, only: %i[show update destroy]
      resources :users
    end
  end
end

# 生成されるルート:
#
# カスタムmemberアクション:
#   POST   /api/v1/articles/:id/publish     api/v1/articles#publish
#   POST   /api/v1/articles/:id/unpublish   api/v1/articles#unpublish
#
# カスタムcollectionアクション:
#   GET    /api/v1/articles/published       api/v1/articles#published
#   GET    /api/v1/articles/drafts          api/v1/articles#drafts

# カスタムアクションの代替案:
#
# RESTfulな設計を優先する場合、カスタムアクションを新しいリソースとして
# 切り出すことを検討すべきです。
#
# 例1: 記事の公開を独立したリソースとして扱う
# resources :articles do
#   resource :publication, only: [:create, :destroy]
# end
# → POST /api/v1/articles/:id/publication (公開)
# → DELETE /api/v1/articles/:id/publication (非公開)
#
# 例2: 公開済み記事を独立したリソースとして扱う
# resources :published_articles, only: [:index, :show]
# → GET /api/v1/published_articles
#
# 判断基準:
# - 新しいリソースとして切り出せるなら、そうすべき
# - カスタムアクションは最小限に留める
# - RESTの原則に従うことで、APIの設計が明確になる

# URLヘルパーの使用:
#
# publish_api_v1_article_path(article)        # /api/v1/articles/:id/publish
# unpublish_api_v1_article_path(article)      # /api/v1/articles/:id/unpublish
# published_api_v1_articles_path              # /api/v1/articles/published
# drafts_api_v1_articles_path                 # /api/v1/articles/drafts
