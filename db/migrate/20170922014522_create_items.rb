class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :uniq_id
      t.references :ownerable, polymorphic: true, index: true # 所有者
      t.integer :item_content_id        # 活动内容
      t.string :title                   # 活动主题
      
      t.references :ruleable, polymorphic: true, index: true # 活动规则
      
      t.integer :view_count, default: 0  # 浏览次数
      t.integer :sent_count, default: 0  # 参与次数
      t.integer :share_count, default: 0 # 分享次数
      
      t.string    :address                      # 活动地址
      t.st_point  :location, geographic: true   # 活动位置，经纬度
      t.integer   :range                        # 活动范围，单位米
      
      t.datetime  :started_at # 活动开始时间
      
      t.string :share_title   # 分享标题
      t.string :share_icon    # 分享图标
      # t.string :share_prize   # 分享奖品 暂时这样设计
      
      t.boolean :opened, default: false
      t.integer :sort, default: 0
      
      t.timestamps null: false
    end
    add_index :items, :uniq_id, unique: true
    add_index :items, :location, using: :gist
    add_index :items, :item_content_id
    add_index :items, :sort
  end
end
