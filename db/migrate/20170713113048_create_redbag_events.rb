class CreateRedbagEvents < ActiveRecord::Migration
  def change
    create_table :redbag_events do |t|
      t.integer :uniq_id
      t.references :ownerable, polymorphic: true, index: true
      t.string :title, null: false
      t.string :image, null: false
      t.text :body, null: false

      t.timestamps null: false
    end
    add_index :redbag_events, :uniq_id, unique: true
  end
end
