class CreateRedpackSendConfigs < ActiveRecord::Migration
  def change
    create_table :redpack_send_configs do |t|
      t.integer :redpack_id
      t.string :send_name, null: false, default: ''
      t.string :wishing,   null: false, default: ''
      t.string :act_name
      t.string :remark
      t.string :scene_id
      
      t.timestamps null: false
    end
    
    add_index :redpack_send_configs, :redpack_id
  end
end
