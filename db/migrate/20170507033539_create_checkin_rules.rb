class CreateCheckinRules < ActiveRecord::Migration
  def change
    create_table :checkin_rules do |t|
      t.string :address, null: false, default: ''
      t.st_point :location, geographic: true 
      t.datetime :checkined_at         # 签到截止时间，备用考虑
      t.integer :accuracy, null: false # 签到精度

      t.timestamps null: false
    end
    add_index :checkin_rules, :location, using: :gist
  end
end
