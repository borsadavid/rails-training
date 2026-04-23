Rails.application.routes.draw do
  # 1. Devise trebuie să fie primul pentru a gestiona Login/Register
  devise_for :users

  # 2. Rutele pentru Postări (Feed, Create, Edit, Delete)
  resources :posts

  # 3. Rutele pentru vizualizarea listei de Useri și a Profilelor
  # Folosim 'only' ca să nu se bată în cap cu rutele de Register/Edit de la Devise
  resources :users, only: [:index, :show]

  # 4. Pagina principală a site-ului (unde ajungi când intri pe localhost:3000)
  # O setăm pe lista de postări
  root "posts#index"

  # Rute de mentenanță și sănătate sistem (opționale, le lăsăm aici)
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end