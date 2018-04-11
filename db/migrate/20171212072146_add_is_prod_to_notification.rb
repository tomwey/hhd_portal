class AddIsProdToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :is_prod, :boolean, default: false
  end
end
