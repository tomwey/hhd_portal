class AddScoreToLuckyDrawItems < ActiveRecord::Migration
  def change
    add_column :lucky_draw_items, :score, :integer # 新增奖项概率
    change_column  :lucky_draw_items, :quantity, :integer, null: true # 移除奖项可抽数量不为空的限制
  end
end
