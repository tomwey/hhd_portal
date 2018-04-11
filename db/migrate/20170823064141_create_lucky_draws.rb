class CreateLuckyDraws < ActiveRecord::Migration
  def change
    create_table :lucky_draws do |t|
      t.integer :uniq_id
      t.references :ownerable, polymorphic: true, index: true
      t.string :title, null: false, default: ''
      t.string :image                        # 封面图
      
      t.string :plate_image, null: false     # 转盘图片
      t.string :arrow_image                  # 转盘箭头图片，如果不设置会用官方默认的
      t.string :background_image             # 抽奖背景图片，如果不设置会用官方默认的
      
      t.st_point :location, geographic: true # 抽奖位置
      t.integer :range                       # 抽奖范围，单位米
      
      t.integer :view_count,  default: 0
      t.integer :share_count, default: 0
      t.integer :draw_count,  default: 0  # 参与抽奖次数
      
      t.datetime :started_at              # 抽奖开始时间,保留字段
      
      t.boolean :opened, default: false
      t.integer :sort, default: 0
      
      t.timestamps null: false
    end
    
    add_index :lucky_draws, :uniq_id, unique: true
    add_index :lucky_draws, :location, using: :gist
    add_index :lucky_draws, :sort
    
  end
end
