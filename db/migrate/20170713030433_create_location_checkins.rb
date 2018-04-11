class CreateLocationCheckins < ActiveRecord::Migration
  def change
    create_table :location_checkins do |t|      
      t.string :address, null: false, default: ''
      t.st_point :location, geographic: true 
      t.integer :accuracy, null: false # 签到精度

      t.timestamps null: false
    end
    add_index :location_checkins, :location, using: :gist
  end
end
