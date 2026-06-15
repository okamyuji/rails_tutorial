Rails.application.routes.draw do
  devise_for :users

  resources :articles do
    resources :comments, only: %i[create destroy]
    member { patch :publish }
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", :as => :rails_health_check

  root "articles#index"
end
