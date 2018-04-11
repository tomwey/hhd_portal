class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.integer :uniq_id
      t.integer :merchant_id
      t.string :address, null: false, default: ''
      t.st_point :location, geographic: true
      t.integer :range, null: false

      t.timestamps null: false
    end
    add_index :areas, :merchant_id
    add_index :areas, :uniq_id, unique: true
    add_index :areas, :location, using: :gist
  end
end
