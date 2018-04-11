class CreatePartins < ActiveRecord::Migration
  def change
    create_table :partins do |t|
      t.integer :uniq_id
      t.integer :merchant_id
      t.integer :item_id
      t.references :ruleable, polymorphic: true, index: true # 参与规则
      t.references :winnable, polymorphic: true, index: true # 参与奖励，例如红包，优惠卡，抽奖等等
      
      t.integer :view_count, default: 0 # 浏览次数
      t.integer :take_count, default: 0 # 参与次数
      t.integer :share_count, default: 0 # 分享次数
      
      # ----------------- 可选设置 ------------------
      t.st_point   :location, geographic: true # 参与位置
      t.string     :location_str               # 参与地址
      t.integer    :range                      # 参与范围，单位米
      t.datetime   :online_at                  # 上线时间
      
      t.string :rule_answer_tip
      
      t.boolean :opened, default: false       # 上架
      t.boolean :need_notify, default: false  # 是否需要上架通知用户
      t.boolean :can_take, default: true      # 是否可以参与
      
      t.integer :sort, default: 0
      
      t.timestamps null: false
    end
    add_index :partins, :uniq_id, unique: true
    add_index :partins, :merchant_id
    add_index :partins, :item_id
    add_index :partins, :sort
    add_index :partins, :location, using: :gist
  end
end
