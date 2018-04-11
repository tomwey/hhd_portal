class CreateRedbags < ActiveRecord::Migration
  def change
    create_table :redbags do |t|
      t.integer :uniq_id
      t.references :ownerable, polymorphic: true, index: true
      t.string :title, null: false
      t.integer :_type, default: 0 # 0 表示随机红包，1 表示固定红包
      t.decimal :total_money, precision: 16, scale: 2, null: false
      t.decimal :min_value, precision: 16, scale: 2, null: false
      t.decimal :max_value, precision: 16, scale: 2, null: false
      
      # 红包已经发出去的金额
      t.decimal :sent_money, default: 0
      
      t.integer :view_count, default: 0 # 红包浏览次数
      t.integer :sent_count, default: 0 # 红包被抢的次数
      t.integer :share_count, default: 0 # 红包被分享次数
      
      t.references :hbable, polymorphic: true, index: true
      t.references :ruleable, polymorphic: true, index: true
      
      t.st_point   :location, geographic: true               # 活动范围
      t.integer    :range                                    # 活动范围，单位千米
      t.datetime   :started_at                               # 活动红包开抢时间
      
      t.boolean :opened, default: false
      
      t.integer :sort, default: 0
      
      t.timestamps null: false
    end
    
    add_index :redbags, :uniq_id, unique: true
    add_index :redbags, :location, using: :gist
    add_index :redbags, :sort
  end
end
