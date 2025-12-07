# frozen_string_literal: true

# 基本的なRESTfulルーティング
# これをconfig/routes.rbにコピーして使用します

Rails.application.routes.draw do
  # APIのバージョニング
  namespace :api do
    namespace :v1 do
      # 基本的なresourcesルーティング
      # 標準的な7つのアクション（index, show, create, update, destroy, new, edit）を生成
      # APIモードでは new と edit は不要なので、exceptで除外することが多い
      resources :users
      
      # onlyオプションで必要なアクションのみを生成
      resources :articles, only: [:index, :show, :create, :update, :destroy]
      
      # exceptオプションで不要なアクションを除外
      # resources :articles, except: [:new, :edit]
    end
  end
  
  # ルートパス
  root 'api/v1/articles#index'
end

# 生成されるルート:
#
# Users:
#   GET    /api/v1/users          api/v1/users#index
#   POST   /api/v1/users          api/v1/users#create
#   GET    /api/v1/users/:id      api/v1/users#show
#   PATCH  /api/v1/users/:id      api/v1/users#update
#   PUT    /api/v1/users/:id      api/v1/users#update
#   DELETE /api/v1/users/:id      api/v1/users#destroy
#
# Articles:
#   GET    /api/v1/articles       api/v1/articles#index
#   POST   /api/v1/articles       api/v1/articles#create
#   GET    /api/v1/articles/:id   api/v1/articles#show
#   PATCH  /api/v1/articles/:id   api/v1/articles#update
#   PUT    /api/v1/articles/:id   api/v1/articles#update
#   DELETE /api/v1/articles/:id   api/v1/articles#destroy

# ルートの確認方法:
# rails routes
# rails routes -g articles  # articlesを含むルートのみ表示
# rails routes -c articles  # ArticlesControllerのルートのみ表示
