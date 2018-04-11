class AddUseSessionsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :use_sessions_count, :integer, default: 0
    add_index :users, :use_sessions_count
  end
end
