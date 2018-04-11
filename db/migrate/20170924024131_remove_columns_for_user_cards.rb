class RemoveColumnsForUserCards < ActiveRecord::Migration
  def change
    add_column :user_cards, :used_at, :datetime
  end
end
