class AddNeedShareToPartins < ActiveRecord::Migration
  def change
    add_column :partins, :need_share, :boolean, default: true
  end
end
