class AddVersionToUserSessions < ActiveRecord::Migration
  def change
    add_column :user_sessions, :version, :string, default: ''
  end
end
