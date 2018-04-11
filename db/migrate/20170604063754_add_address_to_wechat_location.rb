class AddAddressToWechatLocation < ActiveRecord::Migration
  def change
    add_column :wechat_locations, :address, :string
    add_column :wechat_locations, :formated_address, :string
  end
end
