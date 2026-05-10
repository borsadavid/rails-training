Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  devise_for :users
  resources :users

  resources :posts do
    resources :comments, only: [:create]
    resource :like, only: [:create, :destroy] # Resource singular pentru like, deoarece un utilizator poate avea doar un like per postare
  end

  root "posts#index"
end