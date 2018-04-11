class CreateMessageTemplates < ActiveRecord::Migration
  def change
    create_table :message_templates do |t|
      t.string :tpl_id, null: false # 微信模板ID
      t.string :title,  null: false 
      t.string :body
      t.string :body_demo

      t.timestamps null: false
    end
  end
end
