Rails.application.routes.draw do
  # 記事リソース（ネストしたコメント付き）
  resources :articles do
    resources :comments, only: %i[create], shallow: true
  end

  # ヘルスチェック
  get "up" => "rails/health#show", :as => :rails_health_check

  # ルートパス
  root "articles#index"
end
