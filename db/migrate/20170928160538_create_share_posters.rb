class CreateSharePosters < ActiveRecord::Migration
  def change
    create_table :share_posters do |t|
      t.integer :uniq_id
      t.string :image, null: false, default: ''
      t.string :title, null: false, default: ''
      t.integer :sender_hb_id
      t.integer :receiver_hb_id

      t.timestamps null: false
    end
    add_index :share_posters, :uniq_id, unique: true
    add_index :share_posters, :sender_hb_id
    add_index :share_posters, :receiver_hb_id
  end
end
