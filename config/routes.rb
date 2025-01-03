Rails.application.routes.draw do
  # Gestion du jeu
  root "games#home"

  resources :games, only: [:new, :create, :show] do
    collection do
      get :tutorial   # Route pour afficher le tutoriel
      get :end        # Route pour afficher l'écran de fin de partie
    end

    member do
      post :roll_dice    # Action pour lancer les dés
      post :next_player  # Action pour passer au joueur suivant
      post :save_score   # Action pour enregistrer le score
    end
  end
end
