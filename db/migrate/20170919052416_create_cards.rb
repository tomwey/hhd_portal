class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :uniq_id
      t.references :ownerable, polymorphic: true, index: true # 所有者
      t.string :image, null: false, default: '' # 卡封面图
      t.string :title, null: false, default: '' # 卡简单说明
      t.text :body,    null: false, default: '' # 卡的使用说明
      t.integer :limit_use_times   # 限制每人使用卡的次数
      t.string  :limit_duration    # 卡的有效期，可能的值为一个整数，表示该卡被用户领取的日期加上这个天数。也可以是一个具体的有效日期
      t.integer :_type, null: false # 卡的类型
      t.string  :discounts, null: false # 卡的优惠，具体值与_type字段相关，如果为固定金额，那么该值表示一个金额，单位为元，如果为固定折扣，那么该值为一个小于1的小数，表示折扣。如果为随机金额，那么该值为一个范围，例如：3-8，那么用户在领取该卡的时候会计算一个具体的优惠金额。如果为随机折扣，那么该值也是一个范围，例如：0.5-0.9，那么用户在领取该卡的时候会计算一个具体的优惠折扣
      t.integer :sent_count,  default: 0 # 该卡被领取的数量
      t.integer :share_count, default: 0 # 该卡被分享的数量
      t.integer :use_count,   default: 0 # 该卡被使用的次数
      
      t.boolean :opened, default: false  # 该卡是否启用

      t.timestamps null: false
    end
    add_index :cards, :uniq_id, unique: true
    
  end
end
