class AddGameIdToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :game_id, :integer
  end
end
