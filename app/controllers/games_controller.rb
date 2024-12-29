class GamesController < ApplicationController
  def home
    # Logique pour la page d'accueil
  end

  def new
    # Initialise un tableau de 4 joueurs pour le formulaire
    @players = Array.new(4) { Player.new }
  end

  def create
    player_names = params[:players].values.reject(&:blank?) # Récupère uniquement les noms renseignés

    if player_names.size.between?(2, 4)
      player_names.each do |name|
        Player.create(name: name) # Crée chaque joueur dans la base de données
      end
      redirect_to root_path, notice: "La partie commence avec #{player_names.size} joueurs !"
    else
      flash[:alert] = "Veuillez entrer entre 2 et 4 joueurs."
      redirect_to new_game_path
    end
  end

  def tutorial
    # Logique pour le tutoriel
  end

  def end
    # Logique pour l'écran de fin de partie
  end
end
