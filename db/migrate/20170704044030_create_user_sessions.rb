class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.integer :user_id
      t.string :uniq_id
      t.datetime :begin_time
      t.datetime :end_time
      t.string :begin_ip
      t.string :end_ip
      t.st_point :begin_loc, geographic: true
      t.st_point :end_loc, geographic: true
      t.string :begin_network
      t.string :end_network

      t.timestamps null: false
    end
    add_index :user_sessions, :user_id
    add_index :user_sessions, :uniq_id, unique: true
    add_index :user_sessions, :begin_loc, using: :gist
    add_index :user_sessions, :end_loc, using: :gist
  end
end
