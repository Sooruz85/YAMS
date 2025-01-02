class GamesController < ApplicationController

  # Désactive la vérification CSRF uniquement pour l'action roll_dice
  protect_from_forgery with: :null_session, only: [:roll_dice]

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
    @game = Game.find(params[:id])
    @dice = Array.new(5) { rand(1..6) } # Initialise 5 dés
    @players = @game.players            # Récupère les joueurs
    @current_player_index = session[:current_player_index] || 0 # Suivi du joueur actif
    @roll_count = session[:roll_count] || 0                     # Nombre de lancers effectués
  end
  def roll_dice
    @game = Game.find(params[:id])

    # Récupère les indices des dés bloqués depuis les paramètres
    kept_dice_indices = params[:kept_dice] || []
    kept_dice_indices = kept_dice_indices.map(&:to_i)

    # Maintient les dés bloqués et relance les autres
    dice = session[:current_dice] || Array.new(5) { rand(1..6) }
    dice.each_with_index do |_, index|
      dice[index] = rand(1..6) unless kept_dice_indices.include?(index)
    end
    session[:current_dice] = dice

    # Gestion des tours
    session[:roll_count] ||= 0
    session[:current_player_index] ||= 0
    session[:roll_count] += 1

    if session[:roll_count] >= 3
      session[:roll_count] = 0
      session[:current_player_index] = (session[:current_player_index] + 1) % @game.players.count
    end

    current_player = @game.players[session[:current_player_index]]

    render json: {
      dice: dice,
      roll_count: session[:roll_count],
      current_player_name: current_player.name,
      kept_dice: kept_dice_indices
    }
  end

  def next_player
    @game = Game.find(params[:id])

    # Met à jour l'index du joueur actuel
    session[:current_player_index] ||= 0
    session[:current_player_index] = (session[:current_player_index] + 1) % @game.players.count

    # Récupère le nouveau joueur actuel
    current_player = @game.players[session[:current_player_index]]

    render json: { current_player_name: current_player.name }, status: :ok
  end




  def tutorial
    # Logique pour le tutoriel
  end

  def end
    # Logique pour l'écran de fin de partie
  end
end
