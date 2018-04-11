class AddSupportsUserPayToUsers < ActiveRecord::Migration
  def change
    add_column :users, :supports_user_pay, :boolean, default: false
  end
end
