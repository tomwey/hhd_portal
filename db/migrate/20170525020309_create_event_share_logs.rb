class CreateEventShareLogs < ActiveRecord::Migration
  def change
    create_table :event_share_logs do |t|
      t.references :event, index: true, foreign_key: true
      t.integer :user_id
      t.string :ip
      t.st_point :location, geographic: true

      t.timestamps null: false
    end
    add_index :event_share_logs, :location, using: :gist
    add_index :event_share_logs, :user_id
  end
end
