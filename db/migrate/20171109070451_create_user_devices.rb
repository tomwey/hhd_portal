class CreateUserDevices < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.integer :user_id
      t.string :uuid, null: false, default: ''
      t.string :model, null: false, default: ''
      t.string :os, null: false, default: ''
      t.string :os_version, null: false, default: ''
      t.boolean :is_virtual, default: false
      t.string :lang_code

      t.timestamps null: false
    end
    add_index :user_devices, :user_id
    add_index :user_devices, :uuid, unique: true
  end
end
