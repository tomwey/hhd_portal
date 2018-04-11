class CreateItemViewLogs < ActiveRecord::Migration
  def change
    create_table :item_view_logs do |t|
      t.references :item, index: true, foreign_key: true
      t.integer :user_id
      t.string :ip
      t.st_point :location, geographic: true

      t.timestamps null: false
    end
    add_index :item_view_logs, :user_id
    add_index :item_view_logs, :location, using: :gist
  end
end
