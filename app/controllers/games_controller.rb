class GamesController < ApplicationController
  protect_from_forgery with: :null_session, only: [:roll_dice, :save_score]

  def new
    @players = Array.new(4) { Player.new }
  end

  def create
    player_names = params[:players].values.reject(&:blank?)
    if player_names.size.between?(2, 4)
      game = Game.create
      player_names.each { |name| Player.create(name: name, game: game) }
      redirect_to game_path(game), notice: "La partie commence avec #{player_names.size} joueurs !"
    else
      flash[:alert] = "Veuillez entrer entre 2 et 4 joueurs."
      redirect_to new_game_path
    end
  end

  def show
    @game = Game.find_by(id: params[:id])
    if @game.nil?
      redirect_to new_game_path, alert: "La partie demandée n'existe pas. Créez une nouvelle partie."
      return
    end

    @players = @game.players
    @current_player_index = session[:current_player_index] || 0
    @roll_count = session[:roll_count] || 0
    @combinations = @game.used_combinations
  end


  def roll_dice
    @game = Game.find(params[:id])

    # Récupère les indices des dés à conserver depuis les paramètres
    kept_dice_indices = (params[:kept_dice] || []).map(&:to_i)

    # Initialise ou utilise les dés existants
    @game.dice ||= Array.new(5) { rand(1..6) }

    # Relance les dés non conservés
    @game.dice.each_with_index do |_, index|
      @game.dice[index] = rand(1..6) unless kept_dice_indices.include?(index)
    end

    # Gestion des lancers et des joueurs
    session[:roll_count] ||= 0
    session[:current_player_index] ||= 0
    session[:roll_count] += 1

    if session[:roll_count] >= 3
      session[:roll_count] = 0
      session[:current_player_index] = (session[:current_player_index] + 1) % @game.players.count
      @game.update(current_player_id: @game.players[session[:current_player_index]].id)
    end

    # Met à jour les dés dans la partie
    @game.update(dice: @game.dice)

    # Retourne une réponse JSON
    render json: {
      dice: @game.dice,
      roll_count: session[:roll_count],
      current_player_name: @game.players[session[:current_player_index]].name,
      kept_dice: kept_dice_indices
    }
  end

  def save_score
    @game = Game.find(params[:id])
    selected_combination = params[:combination]

    if @game.used_combinations[selected_combination] == false
      @game.used_combinations[selected_combination] = true
      if @game.save
        render json: { success: true, message: "#{selected_combination.capitalize} enregistré !" }, status: :ok
      else
        render json: { success: false, message: "Erreur lors de l'enregistrement du score." }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: "#{selected_combination.capitalize} a déjà été utilisé." }, status: :unprocessable_entity
    end
  end

  def next_player
    @game = Game.find(params[:id])

    # Récupère l'index actuel et calcule l'index suivant
    current_index = session[:current_player_index] || 0
    next_index = (current_index + 1) % @game.players.count

    # Met à jour l'index du joueur actuel dans la session
    session[:current_player_index] = next_index

    # Met à jour le joueur actuel dans le modèle `Game`
    @game.update(current_player_id: @game.players[next_index].id)

    # Retourne le nom du joueur suivant
    render json: { current_player_name: @game.players[next_index].name }, status: :ok
  end


end
