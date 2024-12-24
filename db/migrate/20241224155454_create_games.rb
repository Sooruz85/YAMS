class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :current_player_id
      t.json :dice

      t.timestamps
    end
  end
end
