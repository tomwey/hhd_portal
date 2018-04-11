class AddFromTypeToRedbagViewLogs < ActiveRecord::Migration
  def change
    add_column :redbag_view_logs, :from_type, :integer, default: 0
  end
end
