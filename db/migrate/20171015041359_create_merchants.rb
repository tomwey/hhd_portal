class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.integer :uniq_id
      t.string :logo
      t.string :name, null: false, default: ''
      t.string :mobile
      t.string :address
      t.integer :balance, default: 0
      t.integer :auth_type, default: 0 # 0表示没有认证, 1表示普通用户实名认证, 2表示个体工商户认证, 3表示企业认证
      t.boolean :opened, default: true

      t.timestamps null: false
    end
    add_index :merchants, :uniq_id, unique: true
  end
end
