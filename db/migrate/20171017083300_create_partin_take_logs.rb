class CreatePartinTakeLogs < ActiveRecord::Migration
  def change
    create_table :partin_take_logs do |t|
      t.string :uniq_id
      t.references :user, index: true, foreign_key: true
      t.references :partin, index: true, foreign_key: true
      t.references :resultable, polymorphic: true, index: true # 参与规则
      t.string :ip
      t.st_point :location, geographic: true
      t.timestamps null: false
    end
    add_index :partin_take_logs, :uniq_id, unique: true
    add_index :partin_take_logs, :location, using: :gist
    add_index :partin_take_logs, [:user_id, :partin_id], unique: true
  end
end
