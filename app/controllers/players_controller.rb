class PlayersController < ApplicationController
  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to players_path, notice: "Joueur ajouté avec succès !"
    else
      flash[:alert] = "Erreur lors de l'ajout du joueur."
      render :new
    end
  end

  def index
    @players = Player.all
  end

  private

  def player_params
    params.require(:player).permit(:name)
  end
end
