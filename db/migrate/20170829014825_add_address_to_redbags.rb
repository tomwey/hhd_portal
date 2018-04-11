class AddAddressToRedbags < ActiveRecord::Migration
  def change
    add_column :redbags, :address, :string
  end
end
