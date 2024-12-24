Rails.application.routes.draw do
  get 'games/home'
  get 'games/tutorial'
  root "games#home" # Écran d'accueil
  resources :players, only: [:new, :create, :index]
  resources :games, only: [:index, :show, :create] do
    collection do
      get :tutorial # Route pour le tutoriel
      get :end # Route pour l'écran de fin
    end
  end
end
