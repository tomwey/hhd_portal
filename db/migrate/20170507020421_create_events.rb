class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer    :uniq_id                                  # 系统自动生成一个唯一的业务id标识
      t.string     :title, null: false, default: ''          # 活动主题
      t.string     :image, null: false                       # 活动封面图
      t.string     :body                                     # 活动内容
      t.references :ownerable, polymorphic: true, index: true, null: false # 活动所有者
      t.integer    :hbid, index: true                        # 所属的红包
      t.st_point   :location, geographic: true               # 活动范围
      t.integer    :range                                    # 活动范围，单位千米
      t.string     :body_url                                 # 活动内容地址，商家可以自定义自己的活动内容也
      t.datetime   :started_at                               # 活动红包开抢时间
      t.string     :state, default: 'pending'                # 活动信息状态
      t.integer    :view_count,  default: 0                  # 活动浏览次数
      t.integer    :share_count, default: 0                  # 活动分享转发次数
      t.integer    :likes_count, default: 0                  # 活动点赞数
      t.integer    :sent_hb_count, default: 0                # 当前红包红包已经领取了的人数
      t.references :ruleable, polymorphic: true, index: true # 活动规则
      t.integer    :sort, default: 0, index: true            # 显示顺序
      t.timestamps null: false
    end
    add_index :events, :location, using: :gist
    add_index :events, :uniq_id, unique: true
  end
end
