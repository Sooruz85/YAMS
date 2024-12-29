Rails.application.routes.draw do
  # Page d'accueil
  root "games#home"

  # Gestion des joueurs
  resources :players, only: [:new, :create, :index]

  # Gestion du jeu
  resources :games, only: [:new, :create] do
    collection do
      get :tutorial   # Route pour afficher le tutoriel
      get :end        # Route pour afficher l'écran de fin de partie
    end
  end
end
