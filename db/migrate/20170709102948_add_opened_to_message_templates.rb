class AddOpenedToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :opened, :boolean, default: true
  end
end
