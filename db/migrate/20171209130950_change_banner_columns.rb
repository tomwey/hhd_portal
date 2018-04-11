class ChangeBannerColumns < ActiveRecord::Migration
  def change
    add_column :banners, :link_type, :integer, default: 0 # 0 表示banner不能点击 1 链接到一个网页 2 链接到一个系统的资源，比如：红包，优惠卡等
  end
end
