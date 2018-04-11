class ChangeCardsAreasIndex < ActiveRecord::Migration
  def change
    remove_index :cards, :areas
    add_index :cards, :areas, using: 'gin'
  end
end
