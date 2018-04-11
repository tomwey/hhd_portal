class RemoveSupportsUserPayFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :supports_user_pay
  end
end
