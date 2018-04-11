class CreateOfferwallChannels < ActiveRecord::Migration
  def change
    create_table :offerwall_channels do |t|
      t.integer :uniq_id
      t.string :name,            null: false, default: ''
      t.string :icon
      t.string :platform,        null: false, default: ''
      t.string :appid,           null: false, default: ''
      t.string :app_secret,      null: false, default: ''
      t.string :server_secret,   null: false, default: ''
      t.string :task_url
      t.string :req_sig_method,  null: false, default: ''
      t.string :resp_sig_method, null: false, default: ''
      t.string :success_return, default: '200'
      t.string :failure_return, default: '403'
      t.boolean :opened, default: false
      t.integer :sort ,default: 0

      t.timestamps null: false
    end
    add_index :offerwall_channels, :uniq_id, unique: true
    add_index :offerwall_channels, :sort
    add_index :offerwall_channels, :platform
  end
end
