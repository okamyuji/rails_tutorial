# frozen_string_literal: true

# ネストしたRESTfulルーティング
# リソース間の関係性を表現します

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # 記事配下にコメントをネスト
      resources :articles do
        # 記事に属するコメントの一覧と作成のみをネスト
        resources :comments, only: %i[index create]
      end

      # コメントの個別操作は独立したルート
      resources :comments, only: %i[show update destroy]

      # 上記は以下と同等:
      # resources :articles do
      #   resources :comments, shallow: true
      # end
    end
  end
end

# 生成されるルート:
#
# ネストしたルート（記事のコンテキストで実行）:
#   GET    /api/v1/articles/:article_id/comments       api/v1/comments#index
#   POST   /api/v1/articles/:article_id/comments       api/v1/comments#create
#
# 独立したルート（コメントIDだけで実行）:
#   GET    /api/v1/comments/:id                        api/v1/comments#show
#   PATCH  /api/v1/comments/:id                        api/v1/comments#update
#   DELETE /api/v1/comments/:id                        api/v1/comments#destroy

# shallow: trueを使用した場合:
#
# Rails.application.routes.draw do
#   namespace :api do
#     namespace :v1 do
#       resources :articles do
#         resources :comments, shallow: true
#       end
#     end
#   end
# end
#
# これにより、自動的にshallowなルーティングが生成されます:
#   GET    /api/v1/articles/:article_id/comments       api/v1/comments#index
#   POST   /api/v1/articles/:article_id/comments       api/v1/comments#create
#   GET    /api/v1/comments/:id                        api/v1/comments#show
#   PATCH  /api/v1/comments/:id                        api/v1/comments#update
#   DELETE /api/v1/comments/:id                        api/v1/comments#destroy

# ネストの深さに関する注意:
#
# 悪い例（ネストが深すぎる）:
# resources :users do
#   resources :articles do
#     resources :comments do
#       resources :likes
#     end
#   end
# end
# → URL: /users/:user_id/articles/:article_id/comments/:comment_id/likes/:id
#
# 良い例（ネストは1段階に留める）:
# resources :articles do
#   resources :comments, shallow: true
# end
# resources :comments do
#   resources :likes, only: [:create, :destroy]
# end
