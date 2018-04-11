class CreateItemWinLogs < ActiveRecord::Migration
  def change
    create_table :item_win_logs do |t|
      t.string :uniq_id
      t.references :user, index: true, foreign_key: true
      t.references :item, index: true, foreign_key: true
      t.string :ip
      t.st_point :location, geographic: true
      t.references :resultable, polymorphic: true, index: true

      t.timestamps null: false
    end
    add_index :item_win_logs, :uniq_id, unique: true
    add_index :item_win_logs, :location, using: :gist
    add_index :item_win_logs, [:user_id, :item_id], unique: true
  end
end
