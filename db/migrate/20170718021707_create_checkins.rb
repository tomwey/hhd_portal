class CreateCheckins < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.integer :user_id, null: false, index: true
      t.string :ip
      t.st_point :location, geographic: true
      t.decimal :money, precision: 6, scale: 2, null: false, default: 0.0
      t.integer :redbag_id, index: true

      t.timestamps null: false
    end
    add_index :checkins, :location, using: :gist
  end
end
