class Game < ApplicationRecord
  serialize :used_combinations, JSON
  has_many :players, dependent: :destroy

  # Initialisation par défaut des combinaisons utilisées
  after_initialize :initialize_used_combinations

  # Définit le joueur actuel lors de la création
  after_create :set_initial_player

  # Retourne l'index du joueur actuel
  def current_player_index
    return nil unless current_player_id

    players.index { |player| player.id == current_player_id }
  end

  # Retourne le compteur de lancers (par défaut à 0 si non défini)
  def roll_count
    self[:roll_count] || 0
  end

  # Passe au joueur suivant
  def next_player
    return unless players.any?

    current_index = current_player_index || -1
    next_index = (current_index + 1) % players.size
    update(current_player_id: players[next_index].id)
  end

  private

  # Initialise les combinaisons utilisées si elles sont vides
  def initialize_used_combinations
    self.used_combinations ||= {
      "as" => false,
      "deux" => false,
      "trois" => false,
      "quatre" => false,
      "cinq" => false,
      "six" => false,
      "brelan" => false,
      "carré" => false,
      "full" => false,
      "petite suite" => false,
      "grande suite" => false,
      "yams" => false,
      "chance" => false
    }
  end

  # Définit le premier joueur comme joueur actuel
  def set_initial_player
    return unless players.any?

    update(current_player_id: players.first.id)
  end
end
