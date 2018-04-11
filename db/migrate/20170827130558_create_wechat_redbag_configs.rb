class CreateWechatRedbagConfigs < ActiveRecord::Migration
  def change
    create_table :wechat_redbag_configs do |t|
      t.integer :redbag_id
      t.string :send_name, null: false, default: ''
      t.string :wishing,   null: false, default: ''
      t.string :act_name
      t.string :remark
      t.string :scene_id

      t.timestamps null: false
    end
    add_index :wechat_redbag_configs, :redbag_id
  end
end
