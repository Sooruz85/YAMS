class GamesController < ApplicationController
  protect_from_forgery with: :null_session, only: [:roll_dice]

  def home; end

  def new
    @players = Array.new(4) { Player.new }
  end

  def create
    player_names = params[:players].values.reject(&:blank?)
    if player_names.size.between?(2, 4)
      game = Game.new
      if game.save
        player_names.each { |name| Player.create(name: name, game: game) }
        redirect_to game_path(game), notice: "La partie commence avec #{player_names.size} joueurs !"
      else
        flash[:alert] = "Impossible de créer une nouvelle partie."
        redirect_to new_game_path
      end
    else
      flash[:alert] = "Veuillez entrer entre 2 et 4 joueurs."
      redirect_to new_game_path
    end
  end

  def show
    @game = Game.find(params[:id])
    if @game.players.empty?
      redirect_to new_game_path, alert: "Aucun joueur trouvé pour cette partie."
      return
    end
    @players = @game.players
    @current_player_index = session[:current_player_index] || 0
    @roll_count = session[:roll_count] || 0
    @combinations = @game.used_combinations
  end

  def roll_dice
    @game = Game.find(params[:id])
    kept_dice_indices = (params[:kept_dice] || []).map(&:to_i)
    dice = @game.dice || Array.new(5) { rand(1..6) }

    dice.each_with_index do |_, index|
      dice[index] = rand(1..6) unless kept_dice_indices.include?(index)
    end

    session[:roll_count] ||= 0
    session[:current_player_index] ||= 0
    session[:roll_count] += 1

    if session[:roll_count] >= 3
      session[:roll_count] = 0
      session[:current_player_index] = (session[:current_player_index] + 1) % @game.players.count
    end

    @game.update(dice: dice)
    render json: {
      dice: dice,
      roll_count: session[:roll_count],
      current_player_name: @game.players[session[:current_player_index]].name,
      kept_dice: kept_dice_indices
    }
  end

  def next_player
    @game = Game.find(params[:id])
    session[:current_player_index] ||= 0
    session[:current_player_index] = (session[:current_player_index] + 1) % @game.players.count
    render json: { current_player_name: @game.players[session[:current_player_index]].name }, status: :ok
  end

  def tutorial; end
  def save_score
    @game = Game.find(params[:id])

    # Récupérer la combinaison sélectionnée et l'enregistrer
    selected_combination = params[:combination]
    if @game.used_combinations[selected_combination] == false
      @game.used_combinations[selected_combination] = true
      @game.save

      render json: { success: true, message: "#{selected_combination.capitalize} enregistré !" }, status: :ok
    else
      render json: { success: false, message: "#{selected_combination.capitalize} a déjà été utilisé." }, status: :unprocessable_entity
    end
  end

  def end; end
end
