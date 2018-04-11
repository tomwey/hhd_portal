class CreateUserPosterRedbags < ActiveRecord::Migration
  def change
    create_table :user_poster_redbags do |t|
      t.integer :uniq_id
      t.references :user, index: true, foreign_key: true
      t.references :redbag, index: true, foreign_key: true
      t.references :share_poster, index: true, foreign_key: true
      t.datetime :expired_at

      t.timestamps null: false
    end
    add_index :user_poster_redbags, :uniq_id, unique: true
  end
end
