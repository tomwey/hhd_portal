class ChangeColumnsForUserCards < ActiveRecord::Migration
  def change
    remove_column :user_cards, :_type
    remove_column :user_cards, :discounts
  end
end
