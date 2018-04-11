class ChangeIndexesForPartins < ActiveRecord::Migration
  def change
    remove_index :partins, :areas
    add_index :partins, :opened
    add_index :partins, :can_take
    add_index :partins, :online_at
    add_index :partins, :areas, using: 'gin'
  end
end
