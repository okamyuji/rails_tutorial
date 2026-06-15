Rails.application.routes.draw do
  resources :articles do
    resources :comments, shallow: true
  end

  get "up" => "rails/health#show", :as => :rails_health_check

  root "articles#index"
end
