class CreateWechatLocations < ActiveRecord::Migration
  def change
    create_table :wechat_locations do |t|
      t.references :user, index: true, foreign_key: true
      t.string :lat, null: false, default: ''
      t.string :lng, null: false, default: ''
      t.string :precision

      t.timestamps null: false
    end
  end
end
