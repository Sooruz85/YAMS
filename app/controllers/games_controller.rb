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
      # Crée une nouvelle partie
      game = Game.create

      # Associe les joueurs à cette partie
      player_names.each do |name|
        Player.create(name: name, game_id: game.id) # Ajoute les joueurs à la base
      end

      # Redirige vers la page de la partie
      redirect_to game_path(game), notice: "La partie commence avec #{player_names.size} joueurs !"
    else
      flash[:alert] = "Veuillez entrer entre 2 et 4 joueurs."
      redirect_to new_game_path
    end
  end



  def show
    @dice = Array.new(5) { rand(1..6) } # Initialise 5 dés avec des valeurs aléatoires
  end

  def roll_dice
    @dice = Array.new(5) { rand(1..6) } # Génère de nouveaux résultats pour les dés
    render json: { dice: @dice }        # Retourne les résultats en JSON pour un rafraîchissement dynamique
  end

  def tutorial
    # Logique pour le tutoriel
  end

  def end
    # Logique pour l'écran de fin de partie
  end
end
