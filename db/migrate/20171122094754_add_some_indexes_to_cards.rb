class AddSomeIndexesToCards < ActiveRecord::Migration
  def change
    add_index :cards, :opened
    add_index :cards, :quantity
    add_index :cards, :sent_count
  end
end
