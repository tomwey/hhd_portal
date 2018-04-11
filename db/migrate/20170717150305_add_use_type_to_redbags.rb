class AddUseTypeToRedbags < ActiveRecord::Migration
  def change
    add_column :redbags, :use_type, :integer, default: 1 # 1 表示广告红包， 2 表示分享红包
  end
end
