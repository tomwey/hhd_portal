class AddDeviceToUserSessions < ActiveRecord::Migration
  def change
    add_column :user_sessions, :device, :string
  end
end
