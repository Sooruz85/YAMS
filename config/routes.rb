Rails.application.routes.draw do
  # Page d'accueil
  root "games#home"

  # Gestion des joueurs
  resources :players, only: [:new, :create, :index]

  # Gestion du jeu
  resources :games, only: [:new, :create, :show] do
    collection do
      get :tutorial   # Route pour afficher le tutoriel
      get :end        # Route pour afficher l'écran de fin de partie
    end

    member do
      post :roll_dice    # Action pour lancer les dés
      post :next_player  # Action pour passer au joueur suivant
    end
  end
end
